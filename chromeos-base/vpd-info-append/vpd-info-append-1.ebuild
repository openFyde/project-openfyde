# Copyright (c) 2016-2018 The Flint OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Append nesseary infomation for session manager" 
HOMEPAGE="http://www.flintos.io"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/chromeos-login
"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	insinto /etc/init
	doins ${FILESDIR}/ui-collect-machine-info.override
	doins ${FILESDIR}/machine-info.override

	insinto /usr/share/cros/init
	doins ${FILESDIR}/append_vpd_info
	doins ${FILESDIR}/flint-write-machine-info

	dobin ${FILESDIR}/flintsystem
}
