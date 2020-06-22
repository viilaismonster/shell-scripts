#!/bin/bash

this=$0
port=$1
remote=$2
# ssh="autossh -M 2000 -N -f -v"
ssh="ssh -f -N -T"
test_domain=

retry=0
autoagent=0
identity=

shift; shift
while test $# -gt -0; do case $1 in
    --retry ) shift; retry=$1;;
    --test-domain ) shift; test_domain=$1;;
    --ssh-agent ) autoagent=1;;
    --ssh-identity ) shift; identity=$1;;
    - ) shift; testing=$@; break;;
esac; shift; done
testing=$@
if [ "$testing" = "" ]; then
    google=www.google.com
    [[ "$remote" =~ (bj|cn|ali) ]] && google=www.baidu.com
    [ "$test_domain" != "" ] && google=$test_domain
    testing="curl -s --socks5-hostname localhost:$port -k -I -o /dev/null -w %{http_code} https://$google"
fi
# >&2 echo "testing = $testing"

if [ "$port" = "" ] || [ "$remote" = "" ]; then
    >&2 echo "USAGE: $(basename $0) SOCK5_PORT SSH_REMOTE"
    exit 1
fi

retrydelay=3
function on_error {
    echo
    echo "[$remote] failed. "
    update_pid
    if [ "$retry" -ge 0 ]; then
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
    echo
    exit 1  
}

pid=
function update_pid {
    pid=`ps aux|grep ssh|grep $port|grep -v grep|grep -v dproxy.sh|awk '{print $2}'| xargs echo -n ' '`
    pid=`echo $pid`
}
update_pid

if [ "$pid" == "" ];then
    echo -n "[$remote] :$port starting dproxy ... "
    # >&2 echo "nohup $ssh -D $port $remote > /dev/null" 
    nohup $ssh -D $port $remote > /dev/null || on_error
    sleep .2
    echo " started"
else
    echo "[$remote] :$port dproxy already running, pid = $pid"
fi

rstopretry="reset by peer"
if [ "$testing" != "" ]; then
    retry=3
    # ret_file=/dev/null
    ret_file=/tmp/$(basename $0)-test-`date +%s`.tmp
    echo -n "[$remote] testing ... "
    while test $retry -gt 0; do
        err_resp="`$testing 2>&1 >$ret_file`"

        if [ "$err_resp" != "" ] && [ "$err_resp" != "200" ]; then
            echo "$err_resp"
            rm -f $ret_file
            [[ "$err_resp" =~ $rstopretry ]] && on_error
            echo -n "[$remote] retrying $retry "
            for i in $(seq 1 3); do
                echo -n "." && read -t 1 || continue && retry=1
            done
        else
            echo -n "`cat $ret_file` "
            break
        fi
        retry=$((retry-1))
    done
    rm -f $ret_file
    [ $retry -gt 0 ] || on_error
    echo "passed"
fi

if [ "$autoagent" -eq 1 ]; then
    echo -n "verify ssh identities... ${identity:0:6}"
    identities=`ssh $remote ssh-add -l 2>/dev/null | grep "$identity" | grep id_rsa | wc -l | awk '{print $1}'`
    if [ $identities -eq 0 ]; then
        echo -n "need ssh-add! "
        ssh $remote ssh-add || on_error
    else
        echo " identities=$identities."
    fi
fi

echo
sleep .1
