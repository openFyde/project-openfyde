# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

# Copyright (c) 2017 The Flint OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Prepare fydeos default apps"
HOMEPAGE="http://www.flintos.io"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="fydeos_arc +fydeos_store -fydeos_com"
S="${WORKDIR}"

ARC_SETTING_ID="iakadpgajjigiaojnbdmodlngmbkfhag"
FYDEOS_STORE_ID="hidnajblbifdkmheebalalchohohmaef"

RDEPEND=""
# virtual/arc-plus
DEPEND="${RDEPEND}"

src_compile() {
  ${FILESDIR}/build_validations.sh
}

custom_ins() {
	local f="$1"
	local tmp=""
	tmp="${T}/$(basename "$f")"
	if use fydeos_com; then
		sed 's/store\.fydeos\.io/store.fydeos.com/g' "$f" > "$tmp"
		doins "$tmp"
	else
		doins "$f"
	fi
}

src_install(){
  insinto /mnt/stateful_partition/unencrypted/import_extensions
  doins ${FILESDIR}/extensions/*.crx
  use fydeos_arc && doins ${FILESDIR}/arc-extensions/*.crx
  insinto /usr/share/import_extensions/validation
  doins ${FILESDIR}/validations/*
  insinto /usr/share/chromium/extensions
  for cnf in `ls ${FILESDIR}/extensions/*.json`; do
    if  ! use fydeos_store  && [ -n "`echo $cnf |grep ${FYDEOS_STORE_ID}`" ]; then
      continue
    fi
    custom_ins $cnf
  done
  use fydeos_arc && custom_ins ${FILESDIR}/arc-extensions/*.json
}
