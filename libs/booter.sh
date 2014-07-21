#!/bin/bash

booter_progress_name=""
booter_progress_run=""
booter_progress_background_out=/dev/null
booter_mode=0

function booter_config() {
    booter_progress_run=""
    booter_progress_name=""
    while test $# -gt 0; do
        case $1 in 
            "-n" )
                shift
                booter_progress_name=$1
            ;;
            "--local" | "--console" )
                booter_mode=1
            ;;
            "--background" )
                booter_mode=2
            ;;
            "-m" )
                shift
                booter_mode=$1
            ;;
            * )
                booter_progress_run="$@"
                return 0
            ;;
        esac
        shift
    done
}

function booter_stop() {
    PID=`ps aux|grep $booter_progress_name|grep -v grep|awk '{print $2}'`
    if [ "$PID" == "" ]; then
        echo "no pid found"
    else
        echo "stop $PID"
        kill -9 $PID
    fi
}

function booter_start() {
    if [ "$booter_mode" == "0" ]; then
        echo -n "run $booter_progress_name in local or background?(l/B) "
        read local_or_background
        case $local_or_background in
            "" | "b" | "B" )
                booter_mode=2
            ;;
            * )
                booter_mode=1
            ;;
        esac
    fi
    echo "run $booter_progress_name, mode=$booter_mode"
    cfont -yellow "> $booter_progress_run" -reset -n
    if [ "$booter_mode" == "2" ]; then
        nohup $booter_progress_run >> $booter_progress_background_out &
    else
        $booter_progress_run
    fi
}
