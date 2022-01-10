# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"

EGIT_REPO_URI="${OPENFYDE_GIT_HOST_URL}/fydeos_hardware_tuning.git"
EGIT_BRANCH="r96-dev"

inherit git-r3
DESCRIPTION="Tunning system driver and configrations in console mode"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
  insinto /usr/share/hwtuner-script
  doins -r lib
  doins -r menu
  exeinto /usr/share/hwtuner-script
  doexe hwtuner
  doexe hwtuner_info
  dosym /usr/share/hwtuner-script/hwtuner /usr/bin/hwtuner
  dosym /mnt/stateful_partition/unencrypted/gesture/60-user-defined-devices.conf /etc/gesture/60-user-defined-devices.conf
}
