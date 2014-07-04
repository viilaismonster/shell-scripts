#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

fast_mode=1

SSH_BIN=/usr/bin/ssh

function ssh() {
    $SSH_BIN $@
}

do_bench_repeats=5

function do_bench() {
    trace
    cfont -yellow
    echo "do_bench $@"
    cfont -reset
    import timer
    for i in $(seq 1 $do_bench_repeats); do
        timer_start
        echo -n "test $i/$do_bench_repeats..."
        cost="timeout"
        ssh $@ -o ConnectTimeout=5 exit > /dev/null 2>&1 && cost="ok"
        if [ "$cost" == "timeout" ]; then
            cfont -red
        else
            cost="cost `timer_print` second"
            cfont -green
        fi
        echo " $cost"
        cfont -reset
    done
}

case "$1" in 
    '--bench' )
        shift
        do_bench $@ && pass=1
        test_if_pass "benching $@"
        exit 0
    ;;
esac 

ssh $@
