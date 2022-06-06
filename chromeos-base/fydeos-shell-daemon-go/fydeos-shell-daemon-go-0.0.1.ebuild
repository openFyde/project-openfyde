# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI="6"


EGIT_REPO_URI="${OPENFYDE_GIT_HOST_URL}/fydeos-shell-daemon-go.git"
EGIT_BRANCH="r102-dev"

inherit git-r3 golang-build
DESCRIPTION="fydeos shell daemon in golang, the replacement of python version"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="amd64 arm"
IUSE=""

RDEPEND="
  !chromeos-base/fydeos-shell-daemon
  "

DEPEND="${RDEPEND}
  dev-lang/go
  dev-go/dbus
"

EGO_PN="fydeos.com/shell_daemon"


src_compile() {
   GOARCH=$ARCH GO111MODULE=off golang-build_src_compile
}

get_golibdir() {
  echo "/usr/lib/gopath"  
}

src_install() {
  insinto /usr/share/fydeos_shell
  insinto /etc/init
  doins init/fydeos-shell-daemon.conf
  insinto /etc/dbus-1/system.d
  doins dbus/io.fydeos.ShellDaemon.conf
  exeinto /usr/share/fydeos_shell
  doexe script/*
  doexe shell_daemon
}
