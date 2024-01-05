# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI=7

inherit user

DESCRIPTION="empty project"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Fyde"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
    exeinto "/usr/sbin"
    doexe ${FILESDIR}/openfyde-updater.sh
}
