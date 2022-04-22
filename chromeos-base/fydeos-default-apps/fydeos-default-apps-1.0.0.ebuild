# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

# Copyright (c) 2017 The Flint OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Prepare fydeos default apps"
HOMEPAGE="http://www.flintos.io"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="fydeos_arc fydeos_store"
S="${WORKDIR}"

ARC_SETTING_ID="iakadpgajjigiaojnbdmodlngmbkfhag"
FYDEOS_STORE_ID="hidnajblbifdkmheebalalchohohmaef"

RDEPEND=""
# virtual/arc-plus
DEPEND="${RDEPEND}"

src_compile() {
  ${FILESDIR}/build_validations.sh
  cp ${FILESDIR}/policy/fydeos.json .
  if ! use fydeos_store; then
    sed -i "/${FYDEOS_STORE_ID}/d" ./fydeos.json
  fi
  if ! use fydeos_arc; then
    sed -i "/${ARC_SETTING_ID}/d" ./fydeos.json
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
    doins $cnf
  done
  use fydeos_arc && doins ${FILESDIR}/arc-extensions/*.json
  insinto /etc/chromium/policies/managed
  doins fydeos.json
}
