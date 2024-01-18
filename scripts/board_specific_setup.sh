#!/bin/bash
#
. $(dirname ${BASH_SOURCE[0]})/fydeos_version.sh

CHROMEOS_ARC_ANDROID_SDK_VERSION=28
CHROMEOS_ARC_VERSION=10061641
CHROMEOS_VERSION_AUSERVER=https://up.fydeos.io/service/update2
CHROMEOS_VERSION_DEVSERVER=https://devserver.fydeos.io:9999
CHROMEOS_VERSION_TRACK=stable-channel
#CHROMEOS_PATCH=${CHROMEOS_PATCH##*_}
CHROMEOS_PATCH=18

if [[ -n "${CHROMEOS_BUILD}" ]] && [[ -n "${IMAGES_TO_BUILD}" ]] ; then
  CHROMEOS_VERSION_STRING="${CHROMEOS_BUILD}.${CHROMEOS_BRANCH}.${CHROMEOS_PATCH}.$(get_build_number ${CHROMEOS_PATCH})"
  export FYDEOS_RELEASE=$(get_fydeos_release_version)
fi
