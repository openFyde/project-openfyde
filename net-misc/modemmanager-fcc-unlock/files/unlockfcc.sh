#!/bin/bash
FCC_PATH=/usr/share/ModemManager/fcc-unlock.available.d
TMP=/tmp/unlock_modem.log

is_unlocked() {
  grep "$1" $TMP 2>&1 1>/dev/null
  [ $? -eq 0 ]
}

is_quectel() {
  local usb_dev=$(lsusb -d 2c7c:)
  [ -n "$usb_dev" ]
}

modem_not_in_mbim_mode() {
  local cdc_dev=$(ls /dev/cdc-* 2>/dev/null)
  [ -z "$cdc_dev" ]
}

main() {
  local dev=$(basename $1)
  local id=$2
  local unlock=${FCC_PATH}/$id
  local token="${dev}+${id}"
  if is_unlocked $token; then
    return
  fi
  is_quectel && modem_not_in_mbim_mode \
    &&  /usr/sbin/switch_modem_to_mbim_mode.sh /dev/$dev >> $TMP
  if [ -a $unlock ]; then
    $unlock fake_path $dev
    if [ $? -eq 0 ]; then
      echo $token >> $TMP
    fi
  fi
}

main $@
