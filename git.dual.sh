#!/bin/bash

ROOT=~/tool/shell-scripts
echo "$ROOT"
. $ROOT/libs/common.sh

fast_mode=1

if [ "$1" != "all" ]; then
    cfont -red $1 -reset " not a multi command"
    exit 1
fi

shift
cmd=$1
case $cmd in
    'xpush' )
        shift
        while test $# -gt 0; do
            cfont "$cmd" -yellow " $1" -reset " ... "
            shift
        done
        
    ;;
esac


