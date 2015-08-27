#!/bin/bash

route=10.20.0.1
interface=ppp0
ip=$1

while [ "$ip" = "" ]; do
    echo "enter route ip";
    read ip
done

resolved=`cat /etc/hosts | grep $ip  | grep -v "^#" | head -1| awk '{print $1}'`

if [ "$resolved" = "" ] && type dig >/dev/null 2>&1; then
    resolved=`dig +short $ip`
fi

if [ "$resolved" != "" ]; then 
    echo "resolve $ip -> $resolved"
    ip=$resolved
fi


if [ "$2" != "" ]; then route=$2; fi

echo "add route $ip using $route"

sudo route delete $ip > /dev/null
sudo route add $ip/32 -ifp $interface $route
# ping $ip
