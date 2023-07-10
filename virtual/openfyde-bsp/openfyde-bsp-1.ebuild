# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

# Copyright (c) 2017 The Flint OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="A typical non-generic implementation will install any board-specific configuration files and drivers which are not suitable for inclusion in a generic board overlay."
HOMEPAGE="http://fydeos.com"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
    chromeos-base/fydeos-console-issue
    chromeos-base/fydeos-default-apps
    app-i18n/chromeos-pinyin
    chromeos-base/fydeos-shell-daemon-go
    net-misc/fydeos-remote-help
    chromeos-base/fydeos-dev-remote-patch
    chromeos-base/fydeos-stateful-updater
    chromeos-base/fydeos_power_wash
    chromeos-base/fydeos-hardware-tuner
    net-misc/wget
    app-arch/zip
    app-editors/nano
    app-editors/vim
    sys-apps/usb-modeswitch-data
    chromeos-base/openfyde-updater
    chromeos-base/openfyde-utils
"
DEPEND="
    ${RDEPEND}
"
