#!/bin/bash

import_history=""

function import_once() {
    if grep -q "@$1" <<< "$import_history"; then
        return 0
    fi
    import $@
}

function import() {
    pass=0
    if [ "$ROOT" == "" ]; then
        . libs/$1.sh && pass=1
    else
        . "$ROOT/libs/$1.sh" && pass=1
    fi
    if [ $pass -eq 0 ]; then
        echo "import error: $1"
        exit 1
    fi
    import_history="$import_history@$1"
    pass=0
}

import cfont

trace_mode=1
pass=0
fast_mode=0

function await() {
    if [ $fast_mode -eq 0 ]; then
        sleep 1
    fi
}

function trace_cfont() {
    if [ $trace_mode -ne 0 ]; then
        cfont $@
    fi 
}

function trace() {
    if [ $trace_mode -ne 0 ]; then
        echo $@
    fi 
}

function test_if_pass() {
    if [ $pass -eq 0 ]; then
        cfont -red
        echo "error happend when $@"
        trace
        cfont -reset
        exit 1
    else
        if [ "$1" != "" ]; then
            trace_cfont -green 
            trace "$1 done."
            trace
            trace_cfont -reset
        fi
        pass=0
    fi
    await
}

function test_in_list() {
    # return 1 -> not in the list
    test ! -f $2 && return 1
    test "`cat $2|grep $1|wc -l|awk '{print $1}'`" != "0" && return 0
    return 1
}

function args_check() {
    count=$1
    shift
    args_count=0
    # echo "$@"
    for var in "$@"; do
        args_count=$(($args_count+1))
        # echo "+$args_count"
    done

    # echo "$@ find $args_count args"
    if [ "$args_count" != "$count" ]; then
        cfont -red "args number [$count:$args_count] mismatched, using arg with space under current framework will cause unknown problems!"
        echo
        cfont -reset "to turn this error off, use args_check=off before including " -yellow "common.sh" -reset
        echo
        exit 1
    fi

    # echo "args check $args_count -> $count"
}

if [ "$args_check" == "" ]; then
    args_check $# "$@"
    # exit 0
fi
