# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=7

DESCRIPTION="replace chromeos issue file"
HOMEPAGE="https://fydeos.io"

LICENSE="BSD-Fyde"
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
