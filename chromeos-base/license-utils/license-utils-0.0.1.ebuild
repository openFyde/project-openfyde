# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="7"

DESCRIPTION="a script to get license id (openfyde)"
HOMEPAGE="https://fydeos.io"

LICENSE="BSD-Fyde"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

S=$WORKDIR

src_install() {
  exeinto /usr/share/fydeos_shell
  doexe "$FILESDIR"/license-utils.sh
}
