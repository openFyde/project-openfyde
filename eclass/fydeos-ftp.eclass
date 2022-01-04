FYDEBASE_URI="ftp://ftp:ftp@ftp.fydeos.xyz/${PN}"
AMD64_URI="${FYDEBASE_URI}/${PN}-amd64-${PV}.tar.gz"
ARM_URI="${FYDEBASE_URI}/${PN}-arm-${PV}.tar.gz"

RESTRICT+=" mirror"

SRC_URI="amd64? ( ${AMD64_URI} )
        arm?   ( ${ARM_URI} )"

S="${WORKDIR}"
