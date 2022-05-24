#!/bin/bash

# search and apply special patches for chromium of current board
# patches should be located in the path defined by CHROMIUM_PATCHES_PATH
# or overlay-<board>/chromium-patches/

# The variable CHROMIUM_PATCHES_PATH can be defined in make.conf of overlay-<board>
# or make.conf of it's master repositories. 

find_openfyde_patches() {
  local full_patches_dir=""
  full_patches_dir=${CHROMIUM_PATCHES_PATH}

  if [[ -z "$full_patches_dir" ]] || [[ ! -d "${full_patches_dir}" ]]; then
    local patches_dir="chromium-patches"
    local overlay_root=""
    overlay_root=$(echo "${BOARD_OVERLAY}" | awk -F ' ' '{print $NF}')
    full_patches_dir="${overlay_root}/${patches_dir}"
  fi

  if [[ ! -d "${full_patches_dir}" ]]; then
    return
  fi

  einfo "Searching for chromium patches in ${full_patches_dir}"

  find "${full_patches_dir}" -maxdepth 1 -name '*.patch' | sort -d
}

unpatches_openfyde() {
  pushd "${CHROME_ROOT}"/src > /dev/null || die "Cannot chdir to ${CHROME_ROOT}/src"
  find_openfyde_patches | sort -r | while read -r p; do
    patch -R -p1 < "${p}"
  done
  popd || die "Cannot popd from ${CHROME_ROOT}/src"
}

unpatches_when_aborted() {
  trap 'unpatches_openfyde' SIGINT SIGTERM SIGQUIT
}

cros_pre_src_prepare_patches() {
  pushd "${CHROME_ROOT}"/src > /dev/null || die "Cannot chdir to ${CHROME_ROOT}/src"
  find_openfyde_patches | while read -r p; do
    patch -p1 < "${p}" || die
  done
  unpatches_when_aborted
  popd || die "Cannot popd from ${CHROME_ROOT}/src"
}

cros_pre_src_configure_unpatches() {
  unpatches_when_aborted
}

cros_pre_src_compile_unpatches() {
  unpatches_when_aborted
}

cros_pre_src_install_unpatches() {
  unpatches_when_aborted
}

cros_post_src_install_unpatches() {
  unpatches_openfyde
}
