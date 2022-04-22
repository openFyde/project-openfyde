# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

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
