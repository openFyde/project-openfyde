# Copyright 2026 The FydeOS Authors
# Distributed under the terms of the BSD-Google license.

EAPI=7

# fydeos-vnc is not in the repo manifest; stable builds fetch the pinned
# commit from the remote automatically. To workon this package, clone the
# source manually first:
#   git clone "${OPENFYDE_GIT_HOST_URL}/fydeos-vnc.git" \
#       src/fydeos/fydeos-vnc

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
KEYWORDS="~*"
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

	# Upstart jobs: main daemon + noVNC WebSocket proxy sidecar.
	insinto /etc/init
	doins "${S}"/init/fydeos-vncd.conf
	doins "${S}"/init/fydeos-vnc-wsproxy.conf

	# D-Bus system policy for org.fydeos.VncManager.
	insinto /etc/dbus-1/system.d
	doins "${S}"/dbus/org.fydeos.VncManager.conf

	insinto /usr/share/policy
	newins "${S}"/seccomp/fydeos-vncd-seccomp-${ARCH}.policy \
		fydeos-vncd-seccomp.policy

	# tmpfiles.d to create /var/lib/fydeos-vnc at boot.
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
