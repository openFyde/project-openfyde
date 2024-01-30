# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=7

DESCRIPTION="FydeOS remote helper"
HOMEPAGE="https://fydeos.io"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="net-misc/openssh"

DEPEND="${RDEPEND}"

S=${WORKDIR}

src_install() {
  insinto /usr/share/remote-help
  doins ${FILESDIR}/config/*
  fperms 600 /usr/share/remote-help/tunnelkey
  exeinto /usr/share/remote-help
  doexe ${FILESDIR}/script/*
  insinto /etc/init
  doins ${FILESDIR}/etc/*    
}
