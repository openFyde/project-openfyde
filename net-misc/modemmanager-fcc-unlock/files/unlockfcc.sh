#!/bin/bash
FCC_PATH=/usr/share/ModemManager/fcc-unlock.available.d
TMP=/tmp/unlock_modem.log

is_unlocked() {
  grep "$1" $TMP 2>&1 1>/dev/null
  [ $? -eq 0 ]
}

main() {
  local dev=$(basename $1)
  local id=$2
  local unlock=${FCC_PATH}/$id
  local token="${dev}+${id}"
  if is_unlocked $token; then
    return
  fi
  if [ -a $unlock ]; then
    $unlock fake_path $dev
    if [ $? -eq 0 ]; then
      echo $token >> $TMP
    fi
  fi
}

main $@
