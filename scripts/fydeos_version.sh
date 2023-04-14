#!/bin/bash
#
version_config=""
for overlay in ${BOARD_OVERLAY}; do
  version_config=${overlay}/metadata/fydeos_version.txt
done

base_meta=$(dirname ${BASH_SOURCE[0]})/../metadata
base_version_config=${base_meta}/fydeos_version.txt

#chromeos_tag format:${CHROMEOS_BUILD}.${CHROMEOS_BRANCH}.${CHROMEOS_PATCH}
chromeos_tag="CHROMEOS_VERSION"
build_tag="FYDEOS_BUILD"
release_tag="FYDEOS_RELEASE"

get_data() {
    local tag=$1
    local default=$2
    local data=$(grep ${tag} ${version_config})
    if [ -z "${data}" ]; then
        echo "${default}"
    else
        echo ${data#*=}    
    fi
}

get_base_data() {
    local tag=$1
    local default=$2
    local data=$(grep ${tag} ${base_version_config})
    if [ -z "${data}" ]; then
        echo "${default}"
    else
        echo ${data#*=}    
    fi
}

set_data() {
    local tag=$1
    local data=$2
    local predata=$(get_data ${tag})
    if [ -z "${predata}" ]; then
      echo "${tag}=${data}" >> ${version_config}
    else
      sed -i "s/${tag}=.*$/${tag}=${data}/g" ${version_config}    
    fi
}

get_base_chromeos_version() {
  get_base_data ${chromeos_tag}
}

get_build_number() {
    local chrome_version=$1
    local pre_base_version=$(get_base_data ${chromeos_tag})
    local pre_version=$(get_data ${chromeos_tag} ${pre_base_version})
    local pre_build=$(get_data ${build_tag} 1)
    if [ "${chrome_version}" == "${pre_version}" ]; then
        pre_build=$(($pre_build+1))
    else
        set_data ${chromeos_tag} ${chrome_version}
        pre_build=1
    fi
    set_data ${build_tag} ${pre_build}
    echo ${pre_build}
}

get_base_fydeos_release_version() {
  get_base_data ${release_tag}
}

get_fydeos_release_version() {
  local default=$(get_base_fydeos_release_version)
  get_data ${release_tag} ${default}
}
