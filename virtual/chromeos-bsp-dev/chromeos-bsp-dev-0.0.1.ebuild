# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

EAPI="7"

DESCRIPTION="empty project"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
    chromeos-base/fydeos_power_wash
    virtual/fydeos-arch-spec-dev
    virtual/fydeos-chip-spec-dev
    virtual/fydeos-board-spec-dev
"
#fydeos-dev-remote-patch

DEPEND="${RDEPEND}"
