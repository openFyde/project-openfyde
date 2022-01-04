#!/bin/bash
service=fydeos-remote-help

running_state_dir="/run/fydeos_remote_helper"

is_running() {
    [ -n "$(running_state)" ]
}

start_helper() {
    if is_running; then
        echo "the service is already running."
        exit 1
    fi
    for index in $(seq 3); do
        local remote_port=$(shuf -i 10000-65534 -n 1)
        start ${service} DEBUG_REMOTE_PORT=${remote_port} > /dev/null 2>&1
        sleep 1
        if is_running; then
            if [[ ! -d "$running_state_dir" ]]; then
                mkdir -p "$running_state_dir"
            fi
            echo "$remote_port" | tee "$running_state_dir/port"
            exit 0
        fi
    done
    echo "start error"
    exit 1
}

stop_helper() {
    if ! is_running; then
        echo "done."
        rm -f "$running_state_dir/port"
        exit 0
    fi
    stop ${service} > /dev/null 2>&1
    sleep 1
    if ! is_running; then
        rm -f "$running_state_dir/port"
        echo "done."
        exit 0
    else
        echo "stop error."
        exit 1
    fi
}

running_state() {
    status ${service} 2>&1 | grep start/running
}

main() {
    case $1 in
        start_helper | stop_helper | running_state ) $1 ;;
        *) echo "[start_helper | stop_helper | running_state] to run process" ;;
    esac
}

main "$@"
