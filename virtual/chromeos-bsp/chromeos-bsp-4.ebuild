# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

# Copyright (c) 2017 The Flint OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="A typical non-generic implementation will install any board-specific configuration files and drivers which are not suitable for inclusion in a generic board overlay."
HOMEPAGE="http://fydeos.com"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
    !chromeos-base/chromeos-bsp-null
    virtual/fydeos-arch-spec
    virtual/fydeos-chip-spec
    virtual/fydeos-board-spec
    virtual/fydeos-variant-spec
    virtual/fydeos-chromedev-flags
	virtual/openfyde-bsp
	virtual/fydeos-bsp
"
DEPEND="
    ${RDEPEND}
"
