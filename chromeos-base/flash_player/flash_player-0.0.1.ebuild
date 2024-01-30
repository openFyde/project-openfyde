# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=7

DESCRIPTION="flash player"
HOMEPAGE="https://fydeos.io"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="arm amd64"
IUSE=""

RDEPEND="
    chromeos-base/chromeos-chrome
"

DEPEND="${RDEPEND}"
S=${WORKDIR}

src_install() {
  local arch="amd64"
  if use arm; then
    arch="arm"
  fi
  exeinto /opt/google/chrome/pepper
  doexe ${FILESDIR}/${arch}/pepper/libpepflashplayer.so
  insinto /opt/google/chrome/pepper
  doins ${FILESDIR}/${arch}/pepper/pepper-flash.info
}
