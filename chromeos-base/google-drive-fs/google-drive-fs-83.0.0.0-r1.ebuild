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
  local libpath
  use arm && libpath=/usr/lib
  use amd64 && libpath=/usr/lib64
  exeinto ${libpath}
  doexe lib/*

  exeinto /opt/google/drive-file-stream
  doexe bin/drivefs
}
