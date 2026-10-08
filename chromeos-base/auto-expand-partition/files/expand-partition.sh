#!/bin/sh
VERSION="1.0.0"

print_usage() {
  script=$(basename $0)
  echo "$script version:${VERSION} Copyright By FydeOS"
  echo "  Usage: $script -d | --dst <target disk partition>
  Example: $script -d /dev/sda1
  The command will expand the target partition of removable disk with the empty space behind."
  exit
}

is_os_running_from_installer() {
  # if current os isn't running from installer, do not expand
  if [ -x "/usr/sbin/is_running_from_installer" ]; then
    [ "$(/usr/sbin/is_running_from_installer)" = "yes" ]
  else
    # If there's no `is_running_from_installer`, it's an unexpected case,
    # we'd better not do the expansion.
    return 1
  fi
}

# get disk device from partition device.
# para $1: /dev/sda1 return /dev/sda    $1: /dev/mmcblk0p3 return /dev/mmcblk0
parse_disk_dev() {
    local disk=$1
    local disk=$(echo $1 | sed 's/[0-9_]*$//')
    if [ -z "$(echo $disk | grep '/sd')" ]; then
        disk=${disk%p}
    fi
    echo $disk
}

# $1 as /dev/mmcblk0p12 return 12
parse_partition_num() {
    local dev=$1
    echo ${dev##*[a-z]}
}

is_disk() {
 [ -n "$(lsblk -l -o name,type |grep disk| grep $(basename $1))" ]
}

is_partition() {
 local disk=$(parse_disk_dev $1)
 echo $disk
 if ! is_disk $disk; then
   false
   return
 fi
 local partnum=$(parse_partition_num $1)
 echo $partnum
 [ -n "$(partx -s -o nr -n ${partnum}:${partnum} -g $disk)" ]
}

# Size of a block device in 512-byte sectors.
# NB: `partx -b -o size` reports bytes, not sectors, so it must not be used here.
dev_sectors() {
  if [ -x /sbin/blockdev ]; then
    /sbin/blockdev --getsz "$1" 2>/dev/null && return
  fi
  cat "/sys/class/block/$(basename "$1")/size" 2>/dev/null
}

expand_partition() {
  part=$1
  disk=$(parse_disk_dev $part)
  partnum=$(parse_partition_num $part)
  start_sec=$(partx -s -b -g -o start $part)
  last_byte=$(lsblk -b -d -n -o size $disk)
  last_sec=$(($last_byte / 512))
  cur_sec=$(dev_sectors $part)

  # Bail out before doing arithmetic on empty values, which would otherwise
  # abort the script with a shell syntax error.
  if [ -z "$start_sec" ] || [ -z "$last_byte" ] || [ -z "$cur_sec" ]; then
    echo "Cannot determine geometry for $part (start='$start_sec' disk='$last_byte' cur='$cur_sec');"
    echo "refusing to modify the partition table."
    return 0
  fi

  new_sec=$(($last_sec - $start_sec - 10240))

  # Never shrink a partition.
  #
  # cgpt will happily record a size smaller than the filesystem already living
  # in the partition, and resize2fs cannot shrink a mounted filesystem, so the
  # shrink silently sticks. The next boot then fails with
  #   EXT4-fs (sdaN): bad geometry: block count X exceeds size of device (Y)
  # which fails the stateful mount and sends the device into clobber/powerwash.
  #
  # This happens whenever the disk has less than the 10240-sector (5 MiB) tail
  # reserve free behind the partition -- e.g. an image written to a disk barely
  # larger than itself, where there is nothing to expand into in the first place.
  if [ "$new_sec" -le "$cur_sec" ]; then
    echo "No free space behind $part (current ${cur_sec} sectors, computed ${new_sec}); nothing to expand."
    return 0
  fi

  echo "Expanding $part: ${cur_sec} -> ${new_sec} sectors"
  echo "Check disk:$disk partition table..."
  sgdisk -e $disk
  echo "Done"
  echo "Modify partition $partnum..."
  cgpt add -i $partnum -s $new_sec $disk
  echo "Done"
  echo "Notify kernel..."
  # Writing the table is not the same as the kernel believing it, and the
  # difference is the whole bug this guards against: resize2fs sizes the
  # filesystem from the *block device*, so against a stale partition size it
  # grows the filesystem to the old size and reports success. The partition then
  # reads 116 GiB while the filesystem inside it is still 6 GiB, and no later
  # boot retries, because by then the kernel has read the new table at probe
  # time and this function decides there is nothing left to expand.
  #
  # BLKPG, which is what partx issues, is the only form that can work here: on a
  # USB boot / is another partition of this same disk, so BLKRRPART
  # (blockdev --rereadpt) returns EBUSY. It is tried last all the same.
  partx -u $part || true
  if [ "$(dev_sectors $part)" -lt "$new_sec" ]; then
    partx -u --nr $partnum $disk || true
  fi
  if [ "$(dev_sectors $part)" -lt "$new_sec" ]; then
    blockdev --rereadpt $disk || true
  fi

  kern_sec=$(dev_sectors $part)
  if [ -z "$kern_sec" ] || [ "$kern_sec" -lt "$new_sec" ]; then
    echo "Kernel reports ${kern_sec:-unknown} sectors for $part, not ${new_sec}."
    echo "Refusing to resize the filesystem onto a size the kernel does not have:"
    echo "it would silently grow to the stale size and look like it worked."
    return 1
  fi
  echo "Done (kernel reports ${kern_sec} sectors)"

  echo "Resize filesystem on partition..."
  # Replay the journal, then force.
  #
  # Both are needed and neither is optional. resize2fs refuses outright -- "Please
  # run 'e2fsck -f ... ' first" -- whenever s_lastcheck is older than s_mtime, and
  # on a ChromeOS image s_lastcheck is a build-time constant (Nov 2009) while
  # s_mtime becomes now the moment the partition is first mounted. So the
  # unforced call works on the very first boot and never again: measured on the
  # .191 USB, "Last checked: Thu Nov 19 11:00:00 2009" against "Last write time:
  # Thu Oct  8 15:02:20 2026", refused without -f and resizing straight to the
  # full 244161200 sectors with it.
  #
  # And a device that was powered off while stateful was mounted comes back with
  # needs_recovery set, which -f alone does not deal with. e2fsck -p -E
  # journal_only replays it and is a no-op on a clean filesystem.
  #
  # thinpool_migrator does exactly this before its own resize2fs, for the same
  # reasons -- see ReplayExt4Journal() and ShrinkStatefulFilesystem().
  e2fsck -p -E journal_only $part || true
  if ! resize2fs -f $part; then
    echo "resize2fs failed on $part"
    return 1
  fi
  echo "Done"
}

target_partition=""

[ $# -le 1 ] && print_usage

force="false"
while [ $# -gt 0 ]; do
        opt=$1

        case $opt in
                -d | --dst )
                        target_partition=$2
                        shift
                        ;;
                -f | --force )
                        force="true"
                        ;;
                * )
                        print_usage
                        ;;
        esac
        shift
done

if [ "$force" = "false" ]; then
  if ! is_os_running_from_installer; then
    echo "The system is not running from removable disk."
    print_usage
    exit 0
  fi
fi

echo $target_partition
if is_partition $target_partition; then
  expand_partition $target_partition
else
  print_usage 
fi
