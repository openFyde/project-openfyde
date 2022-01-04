# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="4"

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
