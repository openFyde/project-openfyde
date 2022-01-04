# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"

inherit fydeos-ftp

DESCRIPTION="google official input tools for chromeos"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="amd64 arm arm64"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
    insinto /usr/share/chromeos-assets/input_methods
    doins -r *

    insinto /usr/share/chromeos-assets/input_methods/engine.config.bak
	doins "${FILESDIR}"/engine.config.bak/*

    exeinto /usr/share/cros/init
    doexe "${FILESDIR}/ime_connection_checker.sh"

    insinto /etc/init
    doins "${FILESDIR}/init/fydeos-ime-connection-checker.conf"
}
