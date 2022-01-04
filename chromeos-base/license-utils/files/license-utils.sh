#!/bin/bash
#// Copyright 2020 The FydeOS Authors. All rights reserved.
#// Use of this source code is governed by a BSD-style license that can be
#// found in the LICENSE file.
OEM_PATH=/usr/share/oem
LICENSE_ID=license_id
EXPIRE_DATE=expire_date
LICENSE_TYPE=license_type
SERIAL_NUMBER=serial_number
LICENSE=license
SCRIP_NAME="fydeos-license-utils"

license_readable_attrs=(
  $LICENSE_ID
  $EXPIRE_DATE
  $LICENSE_TYPE
  $LICENSE
)

license_writable_attrs=(
  $EXPIRE_DATE
  $LICENSE_TYPE
  $LICENSE
)

get_fix_devices() {
 local devices=$(lsblk -d -p -o NAME,TRAN,SUBSYSTEMS 2>/dev/null | \
  grep -i "\<nvme\> \| \<sata\> \| \<mmc" | \
  grep -v usb | \
  sed 's/\s.*$//' | \
  sort -r)
 if [ -z "$devices" ]; then
   lsblk -d -p -o NAME,TRAN,SUBSYSTEMS 2>/dev/null | \
    grep -i ":nvme:\|:sata:\|:mmc:" | \
    grep -v usb | \
    sed 's/\s.*$//' | \
    sort
 else
   echo $devices
 fi
}

get_device_serial_by_lsblk() {
  lsblk -d $1 -o SERIAL -n  
}

get_disk_serial_by_hdparm() {
  hdparm -i $1 2>/dev/null | grep SerialNo | sed 's/.*SerialNo=\(.*\)/\1/'
}

get_disk_uuid() {
  fdisk -l $1 2>/dev/null | grep "Disk identifier:" | sed 's/^.*:\s//'
}

get_device_mac() {
  local mac=""
  local -r lan_mac_node="/sys/class/net/eth0/address"
  local -r wlan_mac_node="/sys/class/net/wlan0/address"

  if [[ -e "$lan_mac_node" ]]; then
    mac=$(cat "$lan_mac_node")
  elif [[ -e "$wlan_mac_node" ]]; then
    mac=$(cat "$wlan_mac_node")
  else
    mac=$(ifconfig -a | grep ether | head -n1 | awk '{print $2}')
  fi

  if [[ -n "$mac" ]]; then
    mac=$(echo "$mac" | tr -d ':')
  fi

  echo "$mac"
}

get_device_id() {
  local device=$1
  local method="lsblk"
  local id=$(get_device_serial_by_lsblk $device)
  if [ -z "$id" ]; then
    id=$(get_disk_serial_by_hdparm $device)
    method="hdparm"
  fi
  if [ -n "$id" ]; then
    logger -p "user.info" "$SCRIP_NAME get disk $device serial by $method"
  fi
  echo $id
}

try_get_device_id() {
  local id=""
  for device in $(get_fix_devices); do
    id=$(get_device_id $device)
    if [ -n "$id" ]; then
      echo $id
      return
    fi
  done
}

try_get_device_uuid() {
  local id=""
  for device in $(get_fix_devices); do
    id=$(get_disk_uuid $device)
    if [ -n "$id" ]; then
      echo $id
      return
    fi
  done
}

get_fix_id() {
  local id=""
  id=$(try_get_device_id)
  local method="disk serial"
  if [ -z "$id" ]; then
    id=$(get_device_mac)
    method="mac address"
  fi
  if [ -z "$id" ]; then
    id=$(try_get_device_uuid)
    method="disk uuid"
  fi
  if [ -n "$id" ]; then
    echo $id
    logger -p "user.info" "$SCRIP_NAME get fix id by $method"
    return
  fi
  exit 1
}

get_serial_num() {
  vpd -i RO_VPD -g $SERIAL_NUMBER 2>/dev/null 
}

create_id() {
  local id=$(get_serial_num)
  id+=$(get_fix_id)
  echo $id | sha1sum | sed "s/\s*.$//"
}

remount_oem_writable() {
  mount -o remount,rw "$OEM_PATH"
}

get_vpd_value() {
  vpd -i RW_VPD -g $1 2>/dev/null  
}

count_chars() {
  printf $1 | wc -c
}

put_vpd_value() {
  local varname=$1
  local value=$2
  vpd -i RW_VPD -p $(count_chars $value) -s "${varname}=${value}"
}

read_license() {
  local lines
  for var in ${license_readable_attrs[@]}; do
    lines+="\"${var}\":\"$(get_vpd_value $var)\","
  done
  echo "{${lines%,}}"
}

is_writeable(){
  local target=$1
  for attr in ${license_writable_attrs[@]}; do
    if [ "$attr" == "$target" ]; then
      return 0
    fi
  done
  return 1
}

# parm: xxxx=xxxxxx [ xxxxx=xxxxxx ]
write_license() {
  local varname
  local value
  remount_oem_writable
  for var in $@; do
    varname=${var%%=*}
    value=${var#*=}
    if is_writeable $varname; then
      put_vpd_value $varname $value
    fi
  done
}

main() {
  if [ $# -lt 1 ]; then
    exit 1
  fi
  local cmd=$1
  shift
  case $cmd in
    id )  create_id ;;
    read ) read_license ;;
    write ) write_license $@ ;;
    *) echo "no found command:$cmd"; exit 1 ;;
  esac
}

main $@
