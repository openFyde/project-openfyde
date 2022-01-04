# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"
EGIT_REPO_URI="git@gitlab.fydeos.xyz:arf/project-arc-rec-env.git"
EGIT_BRANCH="master"
inherit git-r3

DESCRIPTION="empty project"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="amd64 arm arm64"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
  insinto /usr/share/fydeos_shell/arc-rec/
  doins installer.sh
  doins -r ${FILESDIR}/common/*
  if use amd64; then
    doins ${FILESDIR}/x86_64/arc-rec-x86_64.tar.gz
  elif use arm; then
    doins ${FILESDIR}/arm64/arc-rec-arm64.tar.gz
    exeinto /lib
    doexe ${FILESDIR}/arm64/lib/*
  elif use arm64; then
    doins ${FILESDIR}/arm64/arc-rec-arm64.tar.gz
    exeinto /lib
    doexe ${FILESDIR}/arm64/lib/*
  fi
}
