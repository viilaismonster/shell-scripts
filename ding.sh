#!/bin/bash

ding_host=127.0.0.1
ding_port=10234

function shell_scripts_root() {
    home=~
    echo "$home/tool/shell-scripts"
}

function ding_libs() {
    . `shell_scripts_root`/libs/common.sh
}

function ding() {
    args_count=$#
    while [ $# -gt 0 ]; do
        case $1 in
            "-c" )
                ding_libs
                shift
                cecho $@ | ding
                return
            ;;
            * )
                echo $@ | ding
                return
            ;;
        esac
    done
    while [[ $args_count -eq 0 ]] ; do
        # echo -n "ding > "
        read -r word
        if [ $? -ne 0 ]; then
            return
        fi
        # echo $word
        echo $word | nc $ding_host $ding_port
    done
}

function ding_disconnect_all() {
    echo "exit" | ding
}

function ding_wire() {
    while true; do
        while read -r line; do
            case "$line" in
                "exit" ) 
                    # >&2 echo "ding exit"
                    exit 
                ;;
            esac
            >&2 echo "[ding] - $line"
        done <<< `nc -l $ding_host $ding_port`
        # >&2 echo "nc close"
    done
}

function ding_bg() {
    ding_disconnect_all
    # sleep 1
    echo "+ ding"
    echo ". `shell_scripts_root`/ding.sh; ding_wire &" | bash > /dev/null
}
