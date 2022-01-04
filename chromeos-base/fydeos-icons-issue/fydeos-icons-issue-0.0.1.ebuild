# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"

DESCRIPTION="Fix os-settings and camera app icons after 12.2 OTA"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
S="${FILESDIR}"

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
  insinto /usr/share/fydeos_shell/icons_issue/
  doins ${FILESDIR}/*.tar.gz
  exeinto /usr/share/fydeos_shell/icons_issue/
  doexe ${FILESDIR}/*.sh
}
