#!/bin/bash
#
. $(dirname ${BASH_SOURCE[0]})/fydeos_version.sh

CHROMEOS_VERSION_AUSERVER=https://up.fydeos.io/service/update2
CHROMEOS_VERSION_DEVSERVER=https://devserver.fydeos.io:9999
CHROMEOS_VERSION_TRACK=stable-channel
#CHROMEOS_PATCH=${CHROMEOS_PATCH##*_}
CHROMEOS_PATCH=23

if [[ -n "${CHROMEOS_BUILD}" ]] && [[ -n "${IMAGES_TO_BUILD}" ]] ; then
  CHROMEOS_VERSION_STRING="${CHROMEOS_BUILD}.${CHROMEOS_BRANCH}.${CHROMEOS_PATCH}.$(get_build_number ${CHROMEOS_PATCH})"
  export FYDEOS_RELEASE=$(get_fydeos_release_version)
fi

# The python runtime is on the production image only for websockify
# (fydeos-vnc -> dev-python/websockify / www-apps/novnc). Shrink its
# rootfs cost: compile the stdlib to sourceless bytecode, pack the whole
# /usr/lib/python3.11 tree into a zstd squashfs and leave an empty dir
# as mountpoint.

# Dev/test images are unaffected: their python packages install a full
# separate runtime under /usr/local.
fydeos_squash_python_runtime() {
  local pydir="${root_fs_dir}/usr/lib/python3.11"
  local squash="${root_fs_dir}/usr/lib/python3.11.squash"

  [[ -d "${pydir}" ]] || return 0

  info "Squashing python runtime: compileall -> mksquashfs zstd"

  # Bytecode magic must match the image's dev-lang/python:3.11; the SDK
  # ships the same minor version so the host interpreter is usable.
  sudo python3.11 -m compileall -b -f -q "${pydir}" || return 1
  sudo find "${pydir}" -name '*.py' -delete
  sudo find "${pydir}" -name '__pycache__' -prune -exec rm -rf {} +

  # Build the squash outside the image first: on tight layouts the
  # rootfs may not have room for tree + squash at the same time.
  local tmpdir
  tmpdir=$(mktemp -d) || return 1
  if ! sudo mksquashfs "${pydir}" "${tmpdir}/python3.11.squash" \
      -comp zstd -Xcompression-level 19 -b 128K \
      -no-xattrs -noappend -all-root >/dev/null; then
    sudo rm -rf "${tmpdir}"
    return 1
  fi

  sudo find "${pydir}" -mindepth 1 -delete
  sudo install -m 0644 -o root -g root \
    "${tmpdir}/python3.11.squash" "${squash}"
  sudo rm -rf "${tmpdir}"

  info "python runtime squashed: $(du -h "${squash}" | cut -f1) at ${squash#${root_fs_dir}}"
}

# Overlays stacked on top (project-fydeos) redefine this hook; they must keep
# calling fydeos_squash_python_runtime themselves.
board_finalize_base_image() {
  fydeos_squash_python_runtime || die "fydeos_squash_python_runtime failed"
}
