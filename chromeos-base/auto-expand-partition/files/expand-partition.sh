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

expand_partition() {
  part=$1
  disk=$(parse_disk_dev $part)
  partnum=$(parse_partition_num $part)
  start_sec=$(partx -s -b -g -o start $part)
  last_byte=$(lsblk -b -d -n -o size $disk)
  last_sec=$(($last_byte / 512))
  echo "Check disk:$disk partition table..."
  sgdisk -e $disk
  echo "Done"
  echo "Modify partition $partnum..."
  cgpt add -i $partnum -s $(($last_sec - $start_sec - 10240)) $disk
  echo "Done"
  echo "Notify kernel..."
  partx -u $part
  echo "Done"
  echo "Resize filesystem on partition..."
  resize2fs $part
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
