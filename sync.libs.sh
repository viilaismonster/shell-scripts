#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

ss_lib=$ROOT/libs

test -d $ss_lib && pass=1
test_if_pass "" "$ss_lib not found"

while test $# -gt 0; do
    test -d $1 && pass=1
    test_if_pass "" "$1 not found"

    echo "copy libs to $1"
    # rm -rf $1/libs
    cp -rf $ss_lib $1/
    shift
done
