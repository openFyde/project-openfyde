# Copyright 1999-2021 Gentoo Authors
# Copyright 2026 The FydeOS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# FydeOS fork of portage-stable's websockify-0.10.0-r1. Divergence:
#   numpy dropped from RDEPEND — websockify only uses it to speed up
#   XOR-unmasking of client->server WebSocket frames (noVNC input
#   events; server->client framebuffer data is never masked, RFC 6455)
#   and falls back to pure Python when the import fails. numpy costs
#   ~54 MiB of rootfs, which some boards cannot afford. Upstream
#   removed the numpy path entirely in 0.11.
# Version pinned by profiles/base/package.mask; re-evaluate on uprev
# (>=0.11 needs no fork at all).

EAPI=7

PYTHON_COMPAT=( python3_{8..11} )
inherit distutils-r1

DESCRIPTION="WebSockets support for any application/server"
HOMEPAGE="https://github.com/novnc/websockify"
SRC_URI="
	https://github.com/novnc/websockify/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="*"

RDEPEND=""

distutils_enable_tests pytest

python_test() {
	local deselect=(
		# TODO: incompatible with current jwcrypto? (not a regression)
		tests/test_token_plugins.py::JWSTokenTestCase::test_asymmetric_jwe_token_plugin
	)
	epytest ${deselect[@]/#/--deselect }
}

python_install_all() {
	doman docs/${PN}.1
	distutils-r1_python_install_all
}
