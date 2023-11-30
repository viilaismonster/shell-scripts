#!/bin/bash

freport=$(mktemp)
fping=$(mktemp)
CRESET="\033[0m"
CGREEN="\033[32m"
CYELLOW="\033[33m"
CRED="\033[31m"
NBSP=" "
INFL=
INFR=$NBSP

function inflate {
    len=$1
    shift
    word="$@"
    
    i=${#word}
    while test $i -lt $len; do
        word="$INFL$word$INFR"
        i=$((i+1))
    done

    echo -n $word
}

route=192.168.100.1
interval=0.5
once=0
pps=10
wifi=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep SSID: | awk '{print $2}' | tail -1)

[[ "$wifi" =~ viila ]] && route=10.0.2.1

while test $# -gt 0; do case $1 in
    --route | --ip | -h ) shift; route=$1;;
    --once | -p ) once=1;;
    --interval | -i ) shift; interval=$1;;
    --pps | -f ) shift; pps=$1;;
    * ) >&2 echo "unknown argument: $@"
        exit 1;;
esac; shift; done

ipps=$(echo "1/$pps" | bc -l | sed 's/^\./0./' | sed 's/0*$//')
pitlen=$(echo "$interval*$pps" | bc| awk -F. '{print $1}')
pitlen=$(head -c $pitlen < /dev/zero | tr '\0' '■')
pitmax=$(echo "$interval*$pps+3" | bc| awk -F. '{print $1}')
# echo ipps=$ipps,pitmax=$pitmax

touch $fping
# echo ping=$fping
ping -i $ipps $route | grep --line-buffered "bytes from"  >$fping &

pwc=0
echo -e "$(inflate 12 WIFI)\tRSSI\t$(INFR= INFL=$NBSP inflate 8 TxRate)\t$(inflate $pitmax $pitlen)\tPLR%\t"
while true; do
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I > $freport
    wifi=$(cat $freport |grep SSID: | awk '{print $2}' | tail -1)
    rssi=$(cat $freport |grep CtlRSSI: | awk '{print $2}' | tail -1)
    tx=$(cat $freport |grep lastTxRate: | awk '{print $2}' | tail -1)
    # maxtx=$(cat $freport |grep maxRate: | awk '{print $2}' | tail -1)

    wifi=$(inflate 12 $wifi)
    tx=$(INFR= INFL=$NBSP inflate 4 $tx)

    lines=$(wc -l $fping | awk '{print $1}')
    line0=$(tail -100 $fping|head -1 | grep "ms"|grep "bytes"|tail -1)
    line=$(tail -2 $fping|grep "ms"|grep "bytes"|tail -1)
    pwc0=$(echo $line0 | awk -Ficmp_seq= '{print $2}' | awk '{print $1}')
    pwc2=$(echo $line | awk -Ficmp_seq= '{print $2}' | awk '{print $1}')
    pit=$((pwc2-pwc))
    [ $pit -gt 0 ] && [ $pit -le 20 ] && pit=$(head -c $pit < /dev/zero | tr '\0' '■')
    pit=$(inflate $pitmax $pit)
    pwc=$pwc2
    [ $lines -gt 100 ] && maxl=100 || maxl=$lines
    plr=$((100-100*$maxl/(pwc2-pwc0+1)))
    # plr=${lines}_${maxl}_$((pwc2-pwc0+1))__$plr

    if [ $plr -gt 30 ]; then
        plr="$CRED$plr%$CRESET"
    elif [ $plr -gt 10 ]; then
        plr="$CYELLOW$plr%$CRESET"
    elif [ $plr -eq 0 ]; then
        plr="$CGREEN$plr%$CRESET"
    else
        plr="$plr%"
    fi
 
    echo -e "$wifi\t$rssi\t${tx}Mbps\t$pit\t$plr\t$line"
    [ $once -eq 0 ] || break
    if [ "$lines" != "" ] && [ $lines -ge 1000 ]; then
        # echo > $fping
        tail -100 $fping > $fping.2
        cat $fping.2 > $fping
        rm -f $fping.2
    fi
    sleep $interval
done

