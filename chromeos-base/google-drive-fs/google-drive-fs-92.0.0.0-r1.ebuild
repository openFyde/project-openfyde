# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"

inherit fydeos-ftp

DESCRIPTION="google drive binary files" 
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="amd64 arm"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
  exeinto /opt/google/drive-file-stream
  doexe drive-file-stream/drivefs
}
