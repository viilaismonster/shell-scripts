#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

while true; do
    cfont -dim " ..." -b
    read line
    cfont "\r" -yellow `date` " > " -reset $line
done
