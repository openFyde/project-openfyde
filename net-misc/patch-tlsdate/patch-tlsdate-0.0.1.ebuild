# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

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
