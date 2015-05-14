#!/bin/bash

ROOT=~/tool/shell-scripts
. "$ROOT/libs/common.sh"

fast_mode=1

if [ $# -eq 0 ]; then
    ping 8.8.8.8
    exit
fi

ping_tmp=/tmp/pings
timeout=3
fix=10

function clear_tmp() {
    rm -Rf $ping_tmp$1
    mkdir $ping_tmp$1
}

if [ -d $1 ]; then
    clear_tmp
    ls $1 | while read line; do
        touch $ping_tmp/$line
    done
fi

if [ $# -gt 0 ]; then
    args=$@
    ping $args
    ret=$?
    case $ret in
        64 )
            clear
            clear_tmp
            for addr in $args; do
                touch $ping_tmp/$addr
            done
        ;;
        * )
            exit
        ;;
    esac
fi

if [ ! -d $ping_tmp ]; then
    cfont -red "$ping_tmp not found" -n -reset
fi

function ping_and_record() {
    addr=$1
    touch $ping_tmp/$addr.runtime.cost
    ping -c 1 -t $timeout $addr > /$ping_tmp/$addr.runtime.result
    ret=$?
    result=`cat $ping_tmp/$addr.runtime.result|grep time|head -1`
    # cfont "?" >> $ping_tmp/$addr
    cost=`echo $result| sed 's/.*time=\(.*\)/\1/g'`
    echo $cost > /$ping_tmp/$addr.runtime.cost
    # cat $ping_tmp/$addr | sed 's/.$//g' > $ping_tmp/$addr
    case $ret in
        0 )
            cfont -green "." >> $ping_tmp/$addr
            ;;
        * )
            cfont -red "x" >> $ping_tmp/$addr
            echo "----" > $ping_tmp/$addr.runtime.cost
            ;;
    esac
}

function str_fix() {
    len=$1
    shift
    str=$1"                                                       "
    echo "${str:0:$len}"
}


function print_header() {
    cfont "ping " `ls $ping_tmp |grep -v runtime| wc -l` ", timeout = $timeout" -n
}

function loop() {
    for addr in `ls $ping_tmp|grep -v runtime`; do
        len=`echo $addr | wc -c | awk '{print $1}'`
        if [ $len -gt $fix ]; then
            fix=20
        fi
        if [ $len -gt $fix ]; then
            fix=25
        fi
        if [ $len -gt $fix ]; then
            fix=30
        fi
        if [ $len -gt $fix ]; then
            fix=40
        fi
        ping_and_record $addr > /dev/null &
    done
    
    clear
    print_header

    for addr in `ls $ping_tmp|grep -v runtime`; do
        cfont "`str_fix $fix $addr` "
        cfont "[" -yellow `cat $ping_tmp/$addr.runtime.cost` -reset "] "
        cat $ping_tmp/$addr
        cfont -reset -n
    done

    sleep $timeout
}

clear
print_header

while :
do
    loop
done