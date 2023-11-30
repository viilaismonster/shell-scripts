#!/bin/bash

ROOT=~/tool/shell-scripts
. "$ROOT/libs/common.sh"

fast_mode=1

ping_tmp=/tmp/pings
timeout=1
fix=10
rotate=50

args=$@

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
        --timeout | -i )
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

if [ $# -eq 0 ]; then
    ping 8.8.8.8
    exit
fi

# in dir mode, save each address to $ping_tmp, then foreach files inside $ping_tmp, do ping_and_record
if [ -d $1 ]; then
    clear_tmp
    ls $1 | while read line; do
        cp -f $1/$line $ping_tmp/$line
    done
fi

if [ -f $1 ]; then
    clear_tmp
    cat $1 | while read line; do
        name=`echo $line|awk '{print $1}'`
        resolved=`echo $line|awk '{print $2}'`
        echo "name = $name, resloved = $resolved"
        echo -n $resolved > $ping_tmp/$name
    done
fi

# if not dir mode
if [ ! -d $1 ] && [ ! -f $1 ]; then
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

function platform_ping {
    addr=$1
    timeout=$2
    case "`uname`" in
        "Darwin" )
            ping -c 5 -i $timeout $addr
            return $?
        ;;
        "Linux" )
            ping -c 1 -W $timeout $addr
            return $?
        ;;
        * )
            >&2 echo "unknown platform"
            return 1
        ;;
    esac
}

function ping_and_record() {
    addr=$1
    resolved=$2
    touch $ping_tmp/$addr.runtime.cost
    touch $ping_tmp/$addr.runtime.log
    if [ "$resolved" == "" ]; then 
        raw=`platform_ping $addr $timeout`
        ret=$?
    else
        raw=`platform_ping $resolved $timeout`
        ret=$?
    fi
    # >&2 echo "[ping $addr/$resolved ret=$ret"
    result=`echo $raw|grep time|head -1`
    cost=`echo $result| sed 's/.*time=\(.*\)/\1/g'`
    echo $cost > $ping_tmp/$addr.runtime.cost
    case $ret in
        0 )
            cfont -green "." >> $ping_tmp/$addr.runtime.log
            ;;
        * )
            cfont -red "x" >> $ping_tmp/$addr.runtime.log
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

clen=6
if [ $cfont_off -eq 1 ]; then
    clen=1
fi
rotatec=$(($clen*1*$rotate))
# echo "rotatec = $rotatec"; exit

count=0
function loop() {
    for addr in `ls $ping_tmp|grep -v runtime`; do
        addr_str=$addr
        addr_resolved=`cat $ping_tmp/$addr`
        len=`echo $addr | wc -c | awk '{print $1}'`
        len=$(($len+`echo $addr_resolved|wc -c|awk '{print $1}'`))
        if [ $len -gt $fix ]; then fix=$(($len+4)); fi
        # echo "ping and record $addr, resolved= $addr_resolved"
        ping_and_record $addr $addr_resolved > /dev/null 2>&1 &
        count=$(($count+1))
    done
    
    clear
    print_header


    for addr in `ls $ping_tmp|grep -v runtime`; do
        addr_str=$addr
        addr_resolved=`cat $ping_tmp/$addr`
        if [ "$addr_resolved" != "" ]; then
            addr_str="$addr ($addr_resolved)"
        fi
        cfont "`str_fix $fix $addr_str` "
        cost=`cat $ping_tmp/$addr.runtime.cost`
        cfont "[" -yellow `str_fix 12 $cost` -reset "] : "
        stat=`cat $ping_tmp/$addr.runtime.log | tail -c $rotatec`
        cfont $stat
        xcount=`grep -o 'x' <<< $stat | wc -l|awk '{print $1}'`
        ctotal=`echo -n $stat|wc -c`
        ctotal=$(($ctotal/$clen))
        if [ $xcount -gt 0 ]; then
            cfont -yellow " " $(($xcount*100/$ctotal)) '%'
        fi
        cfont -reset
        cfont -n
    done

    echo "... $count / `jobs -p|wc -l|awk '{print $1}'`"

    sleep $timeout
}

clear
print_header

while :
do
    loop
done
