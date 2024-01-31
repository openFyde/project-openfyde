# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=7

DESCRIPTION="Mount scripts from stateful partition to root partition"

LICENSE="BSD-Fyde"
HOMEPAGE="https://fydeos.io"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_configure() {
  SCRIPT_LIST=(
    "hwtuner-script"
  )
}

src_install() {
  insinto /etc/fydeos_scripts
  LIST_FILE_PATH="${ED}/etc/fydeos_scripts/list"
  cat /dev/null > "${LIST_FILE_PATH}"
  for script_name in "${SCRIPT_LIST[@]}"; do
    echo "$script_name" >> "${LIST_FILE_PATH}"
  done

  insinto /etc/init
  doins "${FILESDIR}"/init/fydeos-scripts-mounter.conf

  exeinto /usr/share/cros/init
  doexe "${FILESDIR}"/scripts/fydeos-scripts-mounter.sh
}
