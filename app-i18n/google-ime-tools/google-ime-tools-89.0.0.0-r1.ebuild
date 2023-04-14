# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI="5"

inherit fydeos-ftp

DESCRIPTION="google official input tools for chromeos"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="amd64 arm arm64"
IUSE="+noarm64"

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
  if ! use arm64; then
    insinto /usr/share/chromeos-assets/input_methods
    doins -r *
  else
    echo "no input tools" > .input_tools
    insinto /usr/share/chromeos-assets/input_methods
    doins .input_tools
  fi
}
