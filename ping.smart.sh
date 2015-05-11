#!/bin/bash

ROOT=~/tool/shell-scripts
. "$ROOT/libs/common.sh"

fast_mode=1

if [ $# -eq 0 ]; then
    ping 8.8.8.8
    exit
fi

ping_tmp=/tmp/pings

if [ -d $1 ]; then
    rm -Rf $ping_tmp
    mkdir $ping_tmp
    ls $1 | while read line; do
        touch $ping_tmp/$line
    done
else
    ping $@
    exit
fi

if [ ! -d $ping_tmp ]; then
    cfont -red "$ping_tmp not found" -n -reset
fi

timeout=3
fix=10

function ping_and_record() {
    addr=$1
    touch $ping_tmp/$addr.runtime.cost
    result=`ping -c 1 -t $timeout $addr|grep time|head -1`
    cost=`echo $result| sed 's/.*time=\(.*\)/\1/g'`
    echo $cost > /$ping_tmp/$addr.runtime.cost
    case $? in
        0 )
            cfont -green "." -reset >> $ping_tmp/$addr
            ;;
        * )
            cfont -red "x" -reset >> $ping_tmp/$addr
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
        echo
    done

    sleep $timeout
}

clear
print_header

while :
do
    loop
done
