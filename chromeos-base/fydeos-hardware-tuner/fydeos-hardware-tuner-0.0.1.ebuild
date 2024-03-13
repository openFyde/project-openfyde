# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=7

EGIT_REPO_URI="${OPENFYDE_GIT_HOST_URL}/fydeos-hardware-tuning.git"
EGIT_BRANCH="main"

inherit git-r3
DESCRIPTION="Tunning system driver and configrations in console mode"
HOMEPAGE="https://fydeos.io"

LICENSE="BSD-Fyde"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

install_scripts() {
  local dir="$1"
  insinto "$dir"
  doins -r lib
  doins -r menu
  exeinto "$dir"
  doexe hwtuner
  doexe hwtuner_info
}

src_install() {
  EXE_TARGET_DIR="/usr/share/hwtuner-script" # mount --bind -o ro,exec "$SRC_TARGET_DIR" "$EXE_TARGET_DIR

  install_scripts "/mnt/stateful_partition/unencrypted/preserve/fydeos_scripts/hwtuner-script"
  install_scripts "/usr/share/fydeos_shell/.fydeos_scripts/hwtuner-script"

  keepdir "$EXE_TARGET_DIR"

  dosym "$EXE_TARGET_DIR/hwtuner" /usr/bin/hwtuner

  dosym /mnt/stateful_partition/unencrypted/gesture/55-alt-touchpad-cmt.conf /etc/gesture/55-alt-touchpad-cmt.conf
  dosym /mnt/stateful_partition/unencrypted/gesture/60-user-defined-devices.conf /etc/gesture/60-user-defined-devices.conf
}
