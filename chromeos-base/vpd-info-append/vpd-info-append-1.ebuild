# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

# Copyright (c) 2016-2018 The Flint OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Append nesseary infomation for session manager" 
HOMEPAGE="https://fydeos.io"

LICENSE="BSD-Fyde"
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
