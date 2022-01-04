#!/bin/bash

RUNNING_JOB=$(basename "$0")

readonly TRUE=0
readonly FALSE=1

readonly INPUT_METHODS_PATH="/usr/share/chromeos-assets/input_methods"
readonly ENGINE_CONFIG="$INPUT_METHODS_PATH/input_tools/engine.config"
readonly ENGINE_CONFIG_ORIGIN="$INPUT_METHODS_PATH/engine.config.bak/engine.config.orig"
readonly ENGINE_CONFIG_MOD="$INPUT_METHODS_PATH/engine.config.bak/engine.config.mod"

log() {
    local message="$1"
    logger -t "${RUNNING_JOB}" "${message}"
}

writeable() {
    mount -o remount,rw /
}

non-writeable() {
    mount -o remount,ro /
}

wait_for_network() {
    SECONDS=0
    local url="http://store.fydeos.com/204"
    while [[ $SECONDS -lt 120 ]]; do
        if curl "$url" > /dev/null 2>&1; then
            return "$TRUE"
        else
            sleep 2
        fi
    done
    return "$FALSE"
}

is_accessible() {
    local url="https://dl.google.com/dl/inputtools/chrome/9.7.0.0/engine.config"
    if curl -I "$url" --max-time 8 > /dev/null 2>&1; then
        return "$TRUE"
    fi
    return "$FALSE"
}

use_orig() {
    writeable
    cp "$ENGINE_CONFIG_ORIGIN" "$ENGINE_CONFIG"
    non-writeable
    log "cp $ENGINE_CONFIG_ORIGIN to $ENGINE_CONFIG"
}

use_mod() {
    writeable
    cp "$ENGINE_CONFIG_MOD" "$ENGINE_CONFIG"
    non-writeable
    log "cp $ENGINE_CONFIG_MOD to $ENGINE_CONFIG"
}

pre_check() {
    if [[ ! -f "$ENGINE_CONFIG_MOD" ]] || [[ ! -f "$ENGINE_CONFIG_ORIGIN" ]]; then
        log "no backup engine.conf files, exit"
        exit 1
    fi
}

main() {
    pre_check
    if ! wait_for_network; then
        log "no available network, exit"
        exit -1
    fi
    local domain="dl.google.com"
    if is_accessible; then
        log "$domain is not blocked"
        use_orig
    else
        log "$domain seems to be blocked"
        use_mod
    fi
}

main
