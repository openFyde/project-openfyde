#!/bin/bash
#

LOG_FILE="/var/log/update_engine.log"
CONFIG_JSON="/etc/payload.json"

http_server_pid=""
log_pid=""
url_prefix="http://127.0.0.1"
#default port of python3 http.server
port="8000"
tmp="$(mktemp -d --tmpdir=/mnt/stateful_partition/)"
payload="update.gz"
json="update.gz.json"

error()
{
    echo $@
    exit 1
}

usage()
{
    echo "$0 [payload]"
    exit 1
}

lets_get_pidst()
{
    local pid="$1"
    if [ -n "$pid"  ]; then
        kill -TERM $pid 2>/dev/null
        pid=""
#        wait 2>/dev/null
    fi

}

kill_all()
{
    lets_get_pidst $http_server_pid
    lets_get_pidst $log_pid
#    mount -oremount,ro /
}

cleanup()
{
    rm -rf "$tmp"
    kill_all
}

[ -z "$1" ] && usage

payload_xz="$(realpath $1)"

[ -f $payload_xz ] || usage

echo "uncompressing payload..."
tar xf $payload_xz -C $tmp

cd $tmp

url="$url_prefix"":""$port/""$payload"

echo "calculating checksum..."
checksum="$(sha256sum $payload | cut -d ' ' -f1)"

str=",\"payload_url\":\"${url}\",\"sha256sum\":\"${checksum}\"}"

trap cleanup EXIT

set -e

mount -oremount,rw /
cp -f $json $CONFIG_JSON

sed -i "s/}//g" $CONFIG_JSON

echo -n $str >> $CONFIG_JSON

python3 -m http.server &
http_server_pid=$!

sleep 2

echo > $LOG_FILE
tail -f $LOG_FILE &
log_pid=$!

update_engine_client --update

set +e

cleanup
exit 0
