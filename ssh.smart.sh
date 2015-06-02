#!/bin/bash

ROOT=~/tool/shell-scripts
. "$ROOT/libs/common.sh"

fast_mode=1

SSH_BIN=/usr/bin/ssh

function ssh() {
    $SSH_BIN $@
}

repeats=5
timeout=10

do_bench=0
do_bench_repeats=$repeats
do_bench_timeout=$timeout

function do_bench() {
    trace
    cfont -yellow
    echo "do_bench $@ timeout $do_bench_timeout repeat $do_bench_repeats"
    cfont -reset
    import timer
    # for i in $(seq 1 $do_bench_repeats); do
    for (( i=0; i<do_bench_repeats; i++ )); do
        timer_start
        echo -n "test $i/$do_bench_repeats..."
        cost="err"
        if grep -q "^git" <<< "$@"; then
            ssh $@ -o ConnectTimeout=$do_bench_timeout > /dev/null 2>&1 && cost="ok"
        else
            ssh $@ -o ConnectTimeout=$do_bench_timeout exit > /dev/null 2>&1 && cost="ok"
        fi
        if [ "$cost" == "err" ]; then
            cfont -red
            cost="cost `timer_print` second"
            if [ `timer_print` -ge $do_bench_timeout ]; then
                cost="$cost, timeout"
            fi
        else
            cfont -green
            cost="cost `timer_print` second"
        fi
        echo " $cost"
        cfont -reset
    done
}

params=""
params_count=0
while test $# -gt 0; do
    case "$1" in 
        '--bench' )
            do_bench=1
            shift && continue
        ;;
        '--timeout' )
            shift
            timeout=$1
            shift && continue
        ;;
        '--repeat' )
            shift
            repeats=$1
            shift && continue
        ;;
        '--color-off' )
            cfont_off=1
        ;;
    esac 
    params="$params $1"
    params_count=$(($params_count+1))
    shift
done

if [ $do_bench -eq 1 ]; then
    do_bench_timeout=$timeout
    do_bench_repeats=$repeats
    do_bench $params && pass=1
    test_if_pass "benching $@"
    exit 0
fi

# echo $params
args_check $params_count $params
ssh $params
