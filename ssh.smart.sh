#!/bin/bash

ROOT=~/tool/shell-scripts
. "$ROOT/libs/common.sh"

fast_mode=1

SSH_BIN=/usr/bin/ssh

function ssh() {
    $SSH_BIN $@
}

do_bench=0
do_bench_repeats=5
do_bench_timeout=3

repeats=5
timeout=3

function do_bench() {
    trace
    cfont -yellow
    echo "do_bench $@ repeat $do_bench_repeats"
    cfont -reset
    import timer
    # for i in $(seq 1 $do_bench_repeats); do
    for (( i=0; i<do_bench_repeats; i++ )); do
        timer_start
        echo -n "test $i/$do_bench_repeats..."
        cost="timeout"
        if grep -q "^git" <<< "$@"; then
            ssh $@ -o ConnectTimeout=$do_bench_timeout > /dev/null 2>&1 && cost="ok"
        else
            ssh $@ -o ConnectTimeout=$do_bench_timeout exit > /dev/null 2>&1 && cost="ok"
        fi
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

params=""
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
    esac 
    params=$params" "$1
    shift
done

if [ $do_bench -eq 1 ]; then
    do_bench_timeout=$timeout
    do_bench_repeats=$repeats
    do_bench $params && pass=1
    test_if_pass "benching $@"
    exit 0
fi

ssh $params
