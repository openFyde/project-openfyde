# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

# Copyright (c) 2017 The Flint OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Prepare fydeos default apps"
HOMEPAGE="https://fydeos.io"

LICENSE="BSD-Fyde"
SLOT="0"
KEYWORDS="*"
IUSE="fydeos_arc -fydeos_store -fydeos_com fydeos"
S="${WORKDIR}"

ARC_SETTING_ID="iakadpgajjigiaojnbdmodlngmbkfhag"
FYDEOS_STORE_ID="hidnajblbifdkmheebalalchohohmaef"
RHYTHM_ID="nfglebjgiflmmcdddkbcbgmdkomlfcpa"

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
  # FydeOS ships FydeRhythm as a built-in component IME; the store build shares
  # its extension id, gets installed first and shadows the built-in one.
  local crx val
  insinto /mnt/stateful_partition/unencrypted/import_extensions
  for crx in "${FILESDIR}"/extensions/*.crx; do
    if use fydeos && [[ ${crx} == *${RHYTHM_ID}* ]]; then
      continue
    fi
    doins "${crx}"
  done
  # Drop the checksum line as well: encrypted_import aborts the whole import
  # when a listed crx is missing.
  insinto /usr/share/import_extensions/validation
  for val in "${FILESDIR}"/validations/*; do
    if use fydeos; then
      sed "/${RHYTHM_ID}/d" "${val}" > "${T}/${val##*/}" || die "cannot filter ${val}"
      val="${T}/${val##*/}"
    fi
    doins "${val}"
  done
  insinto /usr/share/chromium/extensions
  for cnf in `ls ${FILESDIR}/extensions/*.json`; do
    if  ! use fydeos_store  && [ -n "`echo $cnf |grep ${FYDEOS_STORE_ID}`" ]; then
      continue
    fi
    if use fydeos && [[ ${cnf} == *${RHYTHM_ID}* ]]; then
      continue
    fi
    custom_ins $cnf
  done
}
