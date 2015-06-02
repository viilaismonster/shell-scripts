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
rotate=30

function clear_tmp() {
    rm -Rf $ping_tmp$1
    mkdir $ping_tmp$1
}

while [ $# -gt 0 ]; do
    case $1 in
        --rotate )
            shift
            rotate=$1
        ;;
        --tmp )
            shift
            ping_tmp=$1
        ;;
        --timeout )
            shift
            timeout=$1
        ;;
        --color-off )
            cfont_off=1
        ;;
        * )
            break
        ;;
    esac
    shift
done

# in dir mode, save each address to $ping_tmp, then foreach files inside $ping_tmp, do ping_and_record
if [ -d $1 ]; then
    clear_tmp
    ls $1 | while read line; do
        touch $ping_tmp/$line
    done
fi

# if not dir mode
if [ ! -d $1 ]; then
    args=$@
    # try ping first
    ping $args
    ret=$?
    case $ret in
        64 ) # if not a valid ping command, treat it as dir mode
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
    str=$@" ___________________________________________________________________"
    echo "${str:0:$len}"
}


function print_header() {
    cfont "ping " `ls $ping_tmp |grep -v runtime| wc -l` ", timeout = $timeout, rotate = $rotate" -n
}

if [ $cfont_off -eq 1 ]; then
    rotatec=$((1*$rotate))
else
    rotatec=$((6*$rotate))
fi

function loop() {
    for addr in `ls $ping_tmp|grep -v runtime`; do
        len=`echo $addr | wc -c | awk '{print $1}'`
        if [ $len -gt $fix ]; then fix=$(($len+4)); fi
        ping_and_record $addr > /dev/null &
    done
    
    clear
    print_header


    for addr in `ls $ping_tmp|grep -v runtime`; do
        cfont "`str_fix $fix $addr` "
        cost=`cat $ping_tmp/$addr.runtime.cost`
        cfont "[" -yellow `str_fix 12 $cost` -reset "] :"
        cat $ping_tmp/$addr | tail -c $rotatec
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
