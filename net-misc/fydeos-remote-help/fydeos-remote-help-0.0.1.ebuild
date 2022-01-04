# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"

DESCRIPTION="FydeOS remote helper"
HOMEPAGE="http://fydeos.com"

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
