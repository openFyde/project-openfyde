# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="4"

DESCRIPTION="replace chromeos issue file"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/chromeos-base"

DEPEND="${RDEPEND}"

S=${WORKDIR}

src_install() {
  insinto /etc
  doins ${FILESDIR}/issue
  doins -r ${FILESDIR}/os-release.d
}
