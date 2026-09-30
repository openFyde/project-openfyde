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

is_expanded && exit 0

# Already a physical volume, so this board has migrated and the expansion
# happened before that. Record it and never aim resize2fs at a PV.
if command -v pvs >/dev/null 2>&1 && pvs "${state_dev}" >/dev/null 2>&1; then
  mark_expanded
  exit 0
fi

# Is there anything to gain? On a disk whose STATE already reaches the end there
# is not, and saying so is what keeps this off an installed machine.
start_sec="$(cgpt show -i "${partnum}" -b "${disk}" 2>/dev/null)"
cur_sec="$(cgpt show -i "${partnum}" -s "${disk}" 2>/dev/null)"
disk_bytes="$(lsblk -b -d -n -o size "${disk}" 2>/dev/null)"
if [ -n "${start_sec}" ] && [ -n "${cur_sec}" ] && [ -n "${disk_bytes}" ]; then
  if [ "${cur_sec}" -ge "$(( disk_bytes / 512 - start_sec - SLACK_SECTORS ))" ]; then
    mark_expanded
    exit 0
  fi
fi

log "expanding ${state_dev} before it is mounted"
if /usr/sbin/expand-partition.sh ${FORCE} -d "${state_dev}" \
     > /run/expand-stateful-early.log 2>&1; then
  mark_expanded
  log "expanded ${state_dev}; see /run/expand-stateful-early.log"
else
  # Most often this is expand-partition.sh declining a fixed disk, which is its
  # job. Leave the bit clear: nothing was changed, and the checks above cost
  # two reads of the partition table on the next boot.
  log "did not expand ${state_dev}; see /run/expand-stateful-early.log"
fi
