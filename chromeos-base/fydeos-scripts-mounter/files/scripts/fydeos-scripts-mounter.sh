#!/usr/bin/env bash

declare -r LOG_FILE="/tmp/fydeos-scripts-mounter.log"

declare -r SCRIPT_LIST_FILE="/etc/fydeos_scripts/list"
declare -r SCRIPT_BASE_DIR="/mnt/stateful_partition/unencrypted/preserve/fydeos_scripts"
declare -r FALLBACK_SCRIPT_BASE_DIR="/usr/share/fydeos_shell/.fydeos_scripts"
declare -r TARGET_BASE_SCRIPT="/usr/share"

clear_log() {
  cat /dev/null > "$LOG_FILE"
}

log() {
  echo "$@" >> "$LOG_FILE"
}

is_dir_empty() {
  local dir="$1"
  [[ -z $(find "$dir" -mindepth 1 -maxdepth 1) ]]
}

mount_script() {
  local name="$1"
  local target="$TARGET_BASE_SCRIPT/$name"
  local source="$SCRIPT_BASE_DIR/$name"
  if [[ ! -d "$source" ]] || is_dir_empty "$source"; then
    log "Use fallback script directory: $FALLBACK_SCRIPT_BASE_DIR/$name"
    source="$FALLBACK_SCRIPT_BASE_DIR/$name"
  fi
  log "Preparing to mount from: $source, to: $target"
  # target must be empty directory
  if [[ -d "$source" ]] && [[ -d "$target" ]]; then
    mount --bind -o ro,exec "$source" "$target"
    log "Mounted: $source to: $target"
  else
    log "Invalid script name: $name, no source or target directory found."
  fi
}

main() {
  clear_log
  if [[ ! -f "$SCRIPT_LIST_FILE" ]]; then
    log "Script list file does not exist: $SCRIPT_LIST_FILE"
    exit 1
  fi
  while IFS= read -r name; do
    if [[ -n "$name" ]] && [[ ! "$name" = "#"* ]]; then
      mount_script "$name"
    fi
  done < "$SCRIPT_LIST_FILE"
}

main "$@"
