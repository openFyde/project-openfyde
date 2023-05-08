# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=7

DESCRIPTION="Fydeos stateful updater"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
S="${FILESDIR}"

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
	exeinto /usr/bin
	doexe "${FILESDIR}"/stateful_update_fydeos
	if use arm64; then
		# temporary workaround for arm64, should be removed when next release is out
		newbin "${FILESDIR}"/stateful_update_wrapper_64.sh stateful_update_wrapper.sh
	else
		doexe "${FILESDIR}"/stateful_update_wrapper.sh
	fi
}
