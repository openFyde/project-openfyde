# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI=7

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
