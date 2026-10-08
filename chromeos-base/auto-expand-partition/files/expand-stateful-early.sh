#!/bin/sh
# Copyright (c) 2026 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.
#
# Expand the stateful partition before anything has mounted it.
#
# Usage: expand-stateful-early.sh [-f]      expand if it has not been done
#        expand-stateful-early.sh --is-expanded   just answer, exit 0 if it has
#
# The expansion used to run from an upstart job on "starting boot-services",
# which is after chromeos_startup has mounted stateful. That is too late to
# reshape the partition, and on a board that migrates stateful to an LVM
# thinpool it is too late by a whole boot:
#
#   - The migration runs inside chromeos_startup, before stateful is mounted,
#     because it shrinks the filesystem to make room for thinpool metadata and
#     resize2fs can grow a mounted filesystem but never shrink one.
#   - The thinpool it builds is sized from the partition, and expanding after
#     the fact does not help: expand-partition.sh finishes with resize2fs, which
#     cannot be pointed at a physical volume, so the pool would be stuck at the
#     size the image shipped with.
#
# So the order must be expand, then migrate, both before the mount. This runs on
# "starting startup", which upstart holds until it returns, putting it between
# pre-startup (which has already provided /proc, /sys and /dev) and
# chromeos_startup.
#
# Nothing here may consult .autoexpanded, udev, or anything else living on
# stateful, because none of it exists yet -- and udev is no help either, since
# it starts on "stopped pre-startup" exactly as startup does and so is not
# reliably up.
#
# Whether the work has been done is therefore recorded in the partition table
# itself: one bit of the STATE entry's ChromeOS attribute field. The GPT is
# readable at any point in boot without mounting a thing, it survives a
# powerwash, and a freshly written image has the bit clear because the bit is
# ours and the image was built without it. ChromeOS uses the low ten bits of
# that 16-bit field (priority 0-3, tries 4-7, successful 8, error counter 9,
# per cgptlib_internal.h); bits 10-15 are unused, and this takes the top one.
# It is set with a read-modify-write so the rest of the field is left alone, and
# it survives both `sgdisk -e` and `cgpt add -s`, which the expansion itself
# runs.

# Bit 15 of the raw 16-bit attribute value, i.e. GPT attribute bit 63.
EXPANDED_FLAG=0x8000

# Trailing slack expand-partition.sh leaves at the end of the disk, kept in step
# with it so that "is there anything to gain?" is answered the way it would act.
SLACK_SECTORS=10240

log() {
  logger -t expand-stateful-early "$@"
}

# /dev/sda3 -> /dev/sda1, /dev/nvme0n1p3 -> /dev/nvme0n1p1, worked out the way
# the other jobs on this partition do it.
state_dev="$(rootdev -s 2>/dev/null | sed 's/[0-9_]*$//')1"
disk="$(rootdev -s -d 2>/dev/null)"
partnum="${state_dev##*[a-z]}"

# Reads as 0 or as 0x8000, so let the shell's arithmetic do the base.
attr() {
  local raw
  raw="$(cgpt show -i "${partnum}" -A "${disk}" 2>/dev/null)"
  [ -n "${raw}" ] || return 1
  echo "$(( raw ))"
}

is_expanded() {
  local cur
  cur="$(attr)" || return 1
  [ "$(( cur & EXPANDED_FLAG ))" -ne 0 ]
}

mark_expanded() {
  local cur
  cur="$(attr)" || return 1
  cgpt add -i "${partnum}" -A "$(( cur | EXPANDED_FLAG ))" "${disk}" 2>/dev/null
}

# The kernel's idea of how big the partition is, which is what resize2fs sizes
# the filesystem from -- not the partition table's idea.
dev_sectors() {
  blockdev --getsz "${state_dev}" 2>/dev/null ||
    cat "/sys/class/block/$(basename "${state_dev}")/size" 2>/dev/null
}

# Sectors the filesystem currently covers, or nothing when there is no ext4 to
# ask: a migrated partition is a physical volume, not a filesystem.
fs_sectors() {
  dumpe2fs -h "${state_dev}" 2>/dev/null | awk -F: '
    /^Block count:/ { c = $2 + 0 }
    /^Block size:/  { b = $2 + 0 }
    END { if (c > 0 && b > 0) print c * (b / 512) }'
}

# Does the filesystem fill the partition? This, and not the size of the
# partition, is what "expanded" has to mean. Conflating the two is what let a
# half-done job look finished: the partition read 116 GiB while the filesystem
# inside it was still the 6 GiB the image shipped with, every write landed in
# the 1.25 GiB that was left, and the encrypted /var hit ENOSPC with 65 bursts
# of I/O errors behind it.
fs_fills_partition() {
  local fs part
  fs="$(fs_sectors)"
  part="$(cgpt show -i "${partnum}" -s "${disk}" 2>/dev/null)"
  [ -n "${fs}" ] && [ -n "${part}" ] || return 1
  # resize2fs rounds down to a whole block group -- 32768 blocks, 256 MiB at a
  # 4 KiB block size -- so an exact match is not the test.
  [ "$(( fs + 524288 ))" -ge "${part}" ]
}

# Sync the kernel's view of the partition, then grow the filesystem onto it.
# Kept here rather than left to expand-partition.sh because that script
# declines once the partition is already full size, which is exactly the state
# an interrupted expansion leaves behind.
resize_fs_to_partition() {
  local want
  want="$(cgpt show -i "${partnum}" -s "${disk}" 2>/dev/null)"
  [ -n "${want}" ] || return 1

  partx -u "${state_dev}" || true
  if [ "$(dev_sectors)" -lt "${want}" ]; then
    partx -u --nr "${partnum}" "${disk}" || true
  fi
  if [ "$(dev_sectors)" -lt "${want}" ]; then
    blockdev --rereadpt "${disk}" || true
  fi
  if [ "$(dev_sectors)" -lt "${want}" ]; then
    echo "kernel reports $(dev_sectors) sectors, not ${want}; not resizing"
    return 1
  fi
  resize2fs "${state_dev}"
}

if [ -z "${disk}" ] || [ ! -b "${state_dev}" ]; then
  [ "$1" = "--is-expanded" ] && exit 1
  log "no stateful partition to expand (dev=${state_dev} disk=${disk})"
  exit 0
fi

if [ "$1" = "--is-expanded" ]; then
  is_expanded && exit 0
  exit 1
fi

FORCE=""
[ "$1" = "-f" ] && FORCE="-f"

# A partition that has already been migrated is finished with all of this,
# whatever else is true: it is a physical volume now rather than a filesystem,
# and resize2fs must never be aimed at one. Asked before the done-test below,
# which is about a filesystem that is no longer there.
if command -v pvs >/dev/null 2>&1 && pvs "${state_dev}" >/dev/null 2>&1; then
  mark_expanded
  exit 0
fi

# Done means the filesystem fills the partition. The bit on its own is not
# enough: it only records that this ran, and it is set by a boot that grew the
# partition even if the filesystem never followed.
if is_expanded && fs_fills_partition; then
  exit 0
fi

# How much room is there behind the partition? On a disk whose STATE already
# reaches the end there is none, and saying so is what keeps this off an
# installed machine.
start_sec="$(cgpt show -i "${partnum}" -b "${disk}" 2>/dev/null)"
cur_sec="$(cgpt show -i "${partnum}" -s "${disk}" 2>/dev/null)"
disk_bytes="$(lsblk -b -d -n -o size "${disk}" 2>/dev/null)"
room=yes
if [ -n "${start_sec}" ] && [ -n "${cur_sec}" ] && [ -n "${disk_bytes}" ]; then
  if [ "${cur_sec}" -ge "$(( disk_bytes / 512 - start_sec - SLACK_SECTORS ))" ]; then
    room=
  fi
fi

if [ -n "${room}" ]; then
  log "expanding ${state_dev} before it is mounted"
  /usr/sbin/expand-partition.sh ${FORCE} -d "${state_dev}" \
    > /run/expand-stateful-early.log 2>&1 || true
else
  # The partition is already as big as the disk allows while the filesystem
  # inside it is not. That is an interrupted expansion, and expand-partition.sh
  # would decline it ("nothing to expand") and leave it that way for good, so
  # finish the job here instead.
  log "${state_dev} is full size but its filesystem is not; resizing only"
  resize_fs_to_partition > /run/expand-stateful-early.log 2>&1 || true
fi

# Judged by what the filesystem ended up covering, not by an exit status.
# expand-partition.sh turns down a disk it will not touch -- a fixed one,
# without --force -- by printing a message and exiting *zero*, so its status
# cannot tell success from a polite refusal; and resize2fs against a stale
# kernel partition size grows the filesystem to the old size and also succeeds.
if fs_fills_partition; then
  mark_expanded
  log "the filesystem now fills ${state_dev} ($(fs_sectors) of ${cur_sec:-?} \
sectors); see /run/expand-stateful-early.log"
else
  # Leave the bit clear and let a later boot finish it; the checks above cost
  # two reads of the partition table and one of the superblock.
  log "${state_dev} is not fully expanded yet (filesystem $(fs_sectors) of \
${cur_sec:-?} sectors); see /run/expand-stateful-early.log"
fi
