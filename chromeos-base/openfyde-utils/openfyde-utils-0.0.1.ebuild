# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=7

DESCRIPTION="openfyde utils"
LICENSE="BSD-Fyde"
SLOT="0"
KEYWORDS="*"
IUSE=""
S="${FILESDIR}"

RDEPEND="!chromeos-base/libwidevine"

DEPEND="${RDEPEND}"

src_install() {
	exeinto /usr/bin
	doexe "${FILESDIR}"/enable_libwidevine

  insinto /etc/init
  doins "${FILESDIR}"/init/fydeos-collect-log.conf

  exeinto /usr/share/cros/init
  doexe "${FILESDIR}"/scripts/collect_fydeos_log.sh

  exeinto /usr/sbin
  doexe "${FILESDIR}"/scripts/fydeos_hardware_id
}
