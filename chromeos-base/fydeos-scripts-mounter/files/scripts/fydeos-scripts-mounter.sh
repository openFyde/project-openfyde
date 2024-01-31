#!/usr/bin/env bash

declare -r SCRIPT_LIST_FILE="/etc/fydeos_scripts/list"
declare -r SCRIPT_BASE_DIR="/mnt/stateful_partition/unencrypted/preserve/fydeos_scripts"
declare -r TARGET_BASE_SCRIPT="/usr/share/"

mount_script() {
  local name="$1"
  local target="$TARGET_BASE_SCRIPT/$name"
  local source="$SCRIPT_BASE_DIR/$name"
  # target must be empty directory
  if [[ -d "$source" ]] && [[ -d "$target" ]]; then
    mount --bind -o ro,exec "$source" "$target"
  else
    echo "Invalid script name: $name"
  fi
}

main() {
  if [[ ! -f "$SCRIPT_LIST_FILE" ]]; then
    echo "Script list file does not exist: $SCRIPT_LIST_FILE"
    exit 1
  fi
  while IFS= read -r name; do
    if [[ -n "$name" ]] && [[ ! "$name" = "#"* ]]; then
      mount_script "$name"
    fi
  done < "$SCRIPT_LIST_FILE"
}

main "$@"
