# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="4"

DESCRIPTION="flash player"
HOMEPAGE="http://fydeos.com"

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
