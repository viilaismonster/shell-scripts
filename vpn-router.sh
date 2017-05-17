#!/bin/bash

subnetid=
reset=0

while test $# -gt 0; do case $1 in
    --id ) shift; subnetid=$1;;
    --subnet ) shift; subnet=$1;;
    --vpn | --router ) shift; vpnrouter=$1;;
    --reset ) reset=1;;
    * ) >&2 echo "unknown arguments $@"; exit 1;;
esac; shift; done

[ "$subnetid" = "" ] && >&2 echo "subnetid is empty, usage: $0 --id 20" && exit 1
[ "$subnet" = "" ] && subnet=172.$subnetid.0.0
[ "$vpnrouter" = "" ] && vpnrouter=10.255.$subnetid.1

[ "`sudo whoami`" != "root" ] && exit
sudo route delete $subnet/24 >/dev/null 2>&1

[ $reset -eq 1 ] && exit 0

for i in $(seq 0 9); do 
    ppp=ppp$i
    ifconfig $ppp >/dev/null 2>&1 || break
    # echo "checking $ppp, `ifconfig $ppp | grep $vpnrouter`"
    if ifconfig $ppp | grep $vpnrouter > /dev/null; then
        sudo route add $subnet/24 -ifp $ppp $vpnrouter >/dev/null || exit 1
        echo "network $subnet/24 throuth $ppp($vpnrouter)"
        exit
    fi
done

>&2 echo "error, vpn($vpnrouter -> $subnet) not connected."
exit 1
