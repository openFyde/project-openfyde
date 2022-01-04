# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"

DESCRIPTION="empty project"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/dev-install"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
  :;
}

pkg_postinst() {
  local target_dir=${ROOT}/etc/portage/make.profile
  if [ ! -L $target_dir ]; then
    ln -s -f /usr/share/dev-install/portage/make.profile ${target_dir}
  fi 
}
