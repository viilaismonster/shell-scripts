#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

repack_out_asi=~/tool/repack/out/_asi.apk/smali/asi

test -d $repack_out_asi && pass=1
test_if_pass "" "$repack_out_asi not found"

while test $# -gt 0; do
    test -d $1/smali && pass=1
    test_if_pass "" "$1/smali not found"

    echo "copy asi to $1"
    rm -rf $1/smali/asi
    cp -rf $repack_out_asi $1/smali/
    shift
done
