#!/usr/bin/env bash

set -o errexit

get_serial_number() {
  vpd -i RO_VPD -g "serial_number" 2>/dev/null || echo ""
}

cal_id() {
  local prefix="openfyde"
  local content="$prefix-$1"

  echo "$content" | md5sum | awk '{print $1}' | sha1sum | sed "s/\s*.$//"
}

show_id() {
  local sn
  sn=$(get_serial_number)
  if [[ -z "$sn" ]]; then
    error "Failed to get serial number" >&2
    exit 1
  fi
  local id
  id=$(cal_id "$sn")
  echo "$id"
}

main() {
  # only `license id` is supported
  if [[ ! "$#" -eq 1 ]] || [[ ! "$1" = "id" ]]; then
    echo "Usage: $0 id"
    exit 1
  fi

  show_id
}

main "$@"
