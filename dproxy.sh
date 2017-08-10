#!/bin/bash

this=$0
port=$1
remote=$2

retry=0

shift; shift
while test $# -gt -0; do case $1 in
    --retry ) shift; retry=$1;;
    - ) shift; testing=$@; break;;
esac; shift; done
testing=$@

if [ "$port" = "" ] || [ "$remote" = "" ]; then
    >&2 echo "USAGE: $(basename $0) SOCK5_PORT SSH_REMOTE"
    exit 1
fi

retrydelay=3
function on_error {
    echo "failed."
    update_pid
    if [ "$retry" -gt 0 ]; then
        if [ "$pid" != "" ]; then
            echo -n "killing process $pid ... "
            kill $pid && echo "killed."|| echo "failed."
            retrydelay=10
        fi
        echo "[$remote] retrying. delay $retrydelay remain $retry"
        echo
        sleep $retrydelay
        $this $port $remote --retry $((retry-1)) - $testing
        exit 0
    fi
    exit 1  
}

pid=
function update_pid {
    pid=`lsof -i:$port|grep ssh|tail -1|awk '{print $2}'`
}
update_pid

if [ "$pid" == "" ];then
    echo -n "[$remote] :$port starting dproxy ... "
    nohup ssh -D $port -f -N -T $remote > /dev/null || on_error
    sleep .2
    echo " started"
else
    echo "[$remote] :$port dproxy already running, pid = $pid"
fi

if [ "$testing" != "" ]; then
    echo -n "[$remote] testing ... "
    $testing >/dev/null || on_error
    echo "passed"
fi

echo
sleep .1
