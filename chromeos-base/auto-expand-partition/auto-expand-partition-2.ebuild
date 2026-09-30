# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=7

DESCRIPTION="Auto expand stateful partition on first boot"

LICENSE="BSD-Fyde"
HOMEPAGE="https://fydeos.io"
SLOT="0"
KEYWORDS="*"
IUSE="force"

DEPEND=""
RDEPEND="${DEPEND}
	sys-apps/gptfdisk
"

S=${WORKDIR}

src_install() {
	# Install upstart service
  exeinto "/usr/sbin"
  doexe ${FILESDIR}/expand-partition.sh
  doexe ${FILESDIR}/expand-stateful-early.sh
  insinto "/etc/init"
  if use force; then
    newins ${FILESDIR}/auto-expand-partition.force.conf auto-expand-partition.conf
    newins ${FILESDIR}/expand-stateful-early.force.conf expand-stateful-early.conf
  else
    doins ${FILESDIR}/auto-expand-partition.conf
    doins ${FILESDIR}/expand-stateful-early.conf
  fi
}
