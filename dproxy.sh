#!/bin/bash

port=$1
remote=$2

if [ "$port" = "" ] || [ "$remote" = "" ]; then
    >&2 echo "USAGE: $(basename $0) SOCK5_PORT SSH_REMOTE"
    exit 1
fi

# add d proxy
pid=`lsof -i:$port|grep ssh|tail -1|awk '{print $2}'`
if [ "$pid" == "" ];then
    echo -n "[$remote] :$port starting dproxy"
    nohup ssh -D $port -f -N -T $remote > /dev/null || exit 1
    echo " ... started"
else
    echo "[$remote] :$port dproxy already running, pid = $pid"
fi

