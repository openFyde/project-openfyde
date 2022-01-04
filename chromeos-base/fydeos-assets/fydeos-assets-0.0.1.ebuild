# Copyright 2017 The FydeOS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit toolchain-funcs

DESCRIPTION="Fydeos-specific assets"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
S="${FILESDIR}"

# Force devs to uninstall assets-split first.
RDEPEND="!chromeos-base/chromeos-assets-split"

DEPEND="${RDEPEND}"

src_install() {
	insinto /usr/share/chromeos-assets/images
	doins -r "${FILESDIR}"/images/*

	insinto /usr/share/chromeos-assets/images_100_percent
	doins -r "${FILESDIR}"/images_100_percent/*

	insinto /usr/share/chromeos-assets/images_200_percent
	doins -r "${FILESDIR}"/images_200_percent/*

	insinto /usr/share/chromeos-assets/screensavers
	doins -r "${FILESDIR}"/screensavers/*
	
	insinto /usr/share/chromeos-assets/wallpaper
	doins -r "${FILESDIR}"/wallpaper/*
}
