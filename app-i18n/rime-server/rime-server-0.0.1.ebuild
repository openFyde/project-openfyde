# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
inherit eutils

DESCRIPTION="RIME SERVER"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

BDEPEND="app-i18n/librime"
RDEPEND="${BDEPEND}"
DEPEND="${BDEPEND}"

S=${WORKDIR}


src_prepare () {
	cp -r ${FILESDIR}/* ${WORKDIR}
}

src_install() {
	insinto /etc/init
	doins -r ${WORKDIR}/rime-server.conf

	insinto /usr/share/chromeos-assets/input_methods/rime-conf
	doins -r ${WORKDIR}/rime-conf/*
	fperms -R 777 /usr/share/chromeos-assets/input_methods/rime-conf
}
