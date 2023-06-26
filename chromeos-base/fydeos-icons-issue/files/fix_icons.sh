#!/bin/bash

# a script to fix os-settings and camera app icons

TARGET_PATH_PREFIX="/home/chronos/user/app_service"
TARGET_PATH_SUFFIX="icons"

FIXED_MARK_FILE="$TARGET_PATH_SUFFIX/.fydeos_icon_fixed"

OS_SETTINGS_ICONS_FILE="$(dirname "$0")/os-settings.tar.gz"
CAMERA_APP_ICONS_FILE="$(dirname "$0")/camera.tar.gz"
FILE_MANAGER_ICONS_FILE="$(dirname "$0")/file-manager.tar.gz"


OS_SETTINGS_APPID="odknhmnlageboeamepcngndbggdpaobj"
CAMERA_APPID="njfbnohfdkmbmnjapinfcopialeghnmh"
FILE_MANAGER_APPID="fkiggjmkendpmbegkagpmagjepfkpmeb"

OS_SETTINGS_TARGET_PATH="$TARGET_PATH_PREFIX/$TARGET_PATH_SUFFIX/$OS_SETTINGS_APPID"
CAMERA_APP_TARGET_PATH="$TARGET_PATH_PREFIX/$TARGET_PATH_SUFFIX/$CAMERA_APPID"
FILE_MANAGER_TARGET_PATH="$TARGET_PATH_PREFIX/$TARGET_PATH_SUFFIX/$FILE_MANAGER_APPID"

TMP_OS_SETTINGS_ICONS_PATH="/tmp/os-settings-icons"
TMP_CAMERA_APP_ICONS_PATH="/tmp/camera-app-icons"
TMP_FILE_MANAGER_ICONS_PATH="/tmp/file-manager-icons"

extract_icons() {
	local f="$1"
	local tempdir="$2"
	mkdir -p "$tempdir"
	rm -f "$tempdir/*"
	tar xzf "$f" -C "$tempdir"
}

md5() {
	md5sum "$1" | awk '{print $1}'
}

may_override_file() {
	local file="$1"
	local src_dir="$2"
	local base=""
	local src_file=""
	local origin_md5=""
	local new_md5=""
	base=$(basename "$file")
	src_file="$src_dir/$base"
	if [[ ! -f "$src_file" ]]; then
		return
	fi
	origin_md5=$(md5 "$f")
	new_md5=$(md5 "$src_file")
	if [[ -z "$new_md5" ]] || [[ -z "$origin_md5" ]]; then
		return
	fi
	if [[ "$new_md5" = "$origin_md5" ]]; then
		return
	else
		cp -f "$src_file" "$file"
	fi
}

clean_tmp() {
	local dir="$1"
	if [[ "$dir" != "/tmp/"*  ]]; then
		return
	fi
	rm -f "$dir/"*
	rmdir "$dir"
}

replace_os_settings_icon() {
	extract_icons "$OS_SETTINGS_ICONS_FILE" "$TMP_OS_SETTINGS_ICONS_PATH"
	for f in "$OS_SETTINGS_TARGET_PATH"/*; do
		may_override_file "$f" "$TMP_OS_SETTINGS_ICONS_PATH"
	done
	clean_tmp "$TMP_OS_SETTINGS_ICONS_PATH"
}

replace_camera_app_icon() {
	extract_icons "$CAMERA_APP_ICONS_FILE" "$TMP_CAMERA_APP_ICONS_PATH"
	for f in "$CAMERA_APP_TARGET_PATH"/*; do
		may_override_file "$f" "$TMP_CAMERA_APP_ICONS_PATH"
	done
	clean_tmp "$TMP_CAMERA_APP_ICONS_PATH"
}

replace_file_manager_icon() {
	extract_icons "$FILE_MANAGER_ICONS_FILE" "$TMP_FILE_MANAGER_ICONS_PATH"
	for f in "$FILE_MANAGER_TARGET_PATH"/*; do
		may_override_file "$f" "$TMP_FILE_MANAGER_ICONS_PATH"
	done
	clean_tmp "$TMP_FILE_MANAGER_ICONS_PATH"
}

check_version() {
	local ver=""
	local num=""
	ver=$(grep CHROMEOS_RELEASE_BUILD_TYPE /etc/lsb-release | awk -F '=' '{print $2}')
	num=$(echo "${ver##*Release Build}" | awk '{$1=$1;print}')
	if [[ "$num" != "v17.0" ]]; then
		exit 0
	fi
}

main() {
	check_version
  if [[ -f "$FIXED_MARK_FILE" ]]; then
    exit 0
  fi
	replace_os_settings_icon
	replace_camera_app_icon
  replace_file_manager_icon
  touch "$FIXED_MARK_FILE"
}

main
