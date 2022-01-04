# Copyright 2017 The FydeOS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="FydeOS doctor"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
S="${FILESDIR}"

RDEPEND="!chromeos-base/libwidevine"

DEPEND="${RDEPEND}"

src_install() {
	exeinto /usr/bin
	doexe "${FILESDIR}"/fchk
    # fchk_impl should be upload to cloud
	doexe "${FILESDIR}"/enable_libwidevine
}
