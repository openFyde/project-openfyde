# Copyright 2026 The FydeOS Authors
# Distributed under the terms of the BSD-Google license.

EAPI=7

CROS_WORKON_COMMIT=("853d2734a2a2677a6cc4ef1ad0c28609d8ce3d5d"
                     "9e6ad863a7f1d27a7d285ae82cc51eaff68f09f7")
CROS_WORKON_TREE=("518b50f8b6d01e95cbd933487ed7c6452ac4acb3"
                   "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6"
                   "dbde4aafd1a74f5eba28725efae1de76e156c3b1")

CROS_WORKON_LOCALNAME=("platform2" "fydeos/fydeos-vnc")
CROS_WORKON_PROJECT=("chromiumos/platform2" "fydeos-vnc")
CROS_WORKON_REPO=("https://chromium.googlesource.com"
                   "${OPENFYDE_GIT_HOST_URL}")
CROS_WORKON_SUBTREE=("common-mk .gn" "")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/fydeos-vnc")
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="fydeos-vnc"

inherit cros-workon platform user

DESCRIPTION="FydeOS LAN VNC server daemon"
HOMEPAGE="https://fydeos.io"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

RDEPEND="
	dev-libs/openssl:=
	dev-python/websockify
	media-libs/minigbm:=
	net-libs/libvncserver
	sys-libs/libxcrypt:=
	sys-libs/zlib:=
	www-apps/novnc
	x11-libs/libdrm:=
	x11-libs/libxkbcommon:=
	virtual/opengles
"
DEPEND="${RDEPEND}
	x11-drivers/opengles-headers"

pkg_setup() {
	enewuser fydeos-vnc
	enewgroup fydeos-vnc
}

src_install() {
	platform_src_install

	insinto /etc/init
	doins "${S}"/init/fydeos-vncd.conf
	doins "${S}"/init/fydeos-vnc-wsproxy.conf

	insinto /etc/dbus-1/system.d
	doins "${S}"/dbus/org.fydeos.VncManager.conf

	insinto /usr/share/policy
	newins "${S}"/seccomp/fydeos-vncd-seccomp-${ARCH}.policy \
		fydeos-vncd-seccomp.policy

	insinto /usr/lib/tmpfiles.d
	doins "${S}"/tmpfiles.d/fydeos-vncd.conf

	# Keep `cros deploy` usable on images that bundle this package into
	# the base rootfs: provide the emerge wrapper path and a real
	# python-exec2 under /usr/local.
	dosym /usr/local/lib/python-exec/python3.11/emerge \
		/usr/lib/python-exec/python3.11/emerge
	exeinto /usr/local/lib/python-exec
	newexe "${SYSROOT}"/usr/lib/python-exec/python-exec2 python-exec2
}
