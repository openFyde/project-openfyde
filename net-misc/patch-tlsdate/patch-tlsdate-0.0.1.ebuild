# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"

DESCRIPTION="patch tlsdate config file to get date from bing.com"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="net-misc/tlsdate"

DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_compile() {
    cat ${ROOT}/etc/tlsdate/tlsdated.conf \
        | sed "s/clients3.google.com/dict.bing.com/g" \
        > tlsdated.conf
}

src_install() {
    insinto /etc/tlsdate
    doins tlsdated.conf
}
