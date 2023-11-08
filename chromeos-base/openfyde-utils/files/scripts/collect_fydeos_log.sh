#!/usr/bin/env bash

declare -r TARGET_FILE="/var/log/fydeos.log"

license_id() {
  local bin="/usr/share/fydeos_shell/license-utils.sh"
  "$bin" id
}

release() {
  local lsb_release="/etc/lsb-release"
  local os_release=""
  local browser_release=""
  os_release=$(grep "CHROMEOS_RELEASE_DESCRIPTION" "$lsb_release" | awk -F '=' '{print $2}' | tr -d '\n')
  local chromium_metadata_file="/opt/google/chrome/metadata.json"
  browser_release=$(jq '.content.version' -r "$chromium_metadata_file")

  echo "$os_release (Chromium $browser_release)"
}

board() {
  local file="/etc/lsb-release"
  grep "CHROMEOS_RELEASE_BOARD" "$file" | awk -F '=' '{print $2}'
}

cpu() {
  lscpu
}

memory() {
  free -mt
}

pci() {
  lspci
}

kernel_mod() {
  lsmod
}

usb() {
  lsusb
}

hwtuner() {
  local bin="/usr/bin/hwtuner"
  "$bin" --info
}

collect() {
  local func="$1"
  local name=""
  local prefix=""
  local suffix=""
  name=$(echo "$func" | tr '[:lower:]' '[:upper:]')
  prefix="==================== $name ===================="
  suffix=$(printf '=%.0s' $(seq 1 ${#prefix}))

  local result=""
  result=$(eval "$func" 2> /dev/null)
  echo -e "$prefix\n$result\n$suffix\n" >> "$TARGET_FILE"
}

empty() {
  cat /dev/null > "$TARGET_FILE"
}

main() {
  empty
  collect license_id
  collect release
  collect board
  collect cpu
  collect memory
  # collect pci
  # collect usb
  collect kernel_mod
  collect hwtuner
}

main "$@"
