# Copyright 1999-2021 Gentoo Authors
# Copyright 2026 The FydeOS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_SETUPTOOLS=no
PYTHON_COMPAT=( python3_{8..11} )
inherit distutils-r1

DESCRIPTION="noVNC is a VNC client implemented using HTML5 technologies"
HOMEPAGE="https://github.com/novnc/noVNC"

if [[ ${PV} == *9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/kanaka/noVNC.git"
else
	SRC_URI="https://github.com/kanaka/noVNC/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="*"
	S="${WORKDIR}/noVNC-${PV}"
fi

LICENSE="LGPL-3"
SLOT="0"

# numpy dropped alongside the dev-python/websockify fork in this
# overlay: noVNC itself is static HTML/JS and never imports numpy;
# the dependency came from stock websockify's optional unmask
# acceleration. Saves ~54 MiB of rootfs.
RDEPEND="
	dev-python/websockify[${PYTHON_USEDEP}]"

PATCHES=(
	"${FILESDIR}/fydeos-plain-password-only.patch"
)

python_compile() {
	:
}

src_install() {
	exeinto /usr/share/novnc/utils
	for f in utils/*; do
		[[ ! f = utils/README.md ]] && doexe $f
	done

	dodoc README.md LICENSE.txt

	# browser-es-module-loader is a `nomodule` polyfill for pre-2017
	# browsers with no native ES module support; every browser FydeOS
	# supports ignores nomodule scripts, and the shim costs ~3.9 MiB.
	# pako (zlib in JS) and promise.js stay: core/ imports pako.
	rm -r vendor/browser-es-module-loader || die

	insinto /usr/share/novnc
	doins -r vnc.html vnc_lite.html app/ core/ vendor/
	dosym vnc_lite.html /usr/share/novnc/vnc_auto.html  # for compat
	dosym ../share/novnc/utils/launch.sh /usr/bin/novnc
}
