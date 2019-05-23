
timer_start_at=''
timer_start_atms=''

timer_date_bin=date
if which gdate >/dev/null 2>&1; then
    timer_date_bin=gdate 
fi
function timer_date() {
    $timer_date_bin "$@"
}

function timer_start() {
    timer_start_at=$(timer_date "+%s")
    timer_start_atms=$(($(timer_date "+%s%N")/1000000))
    # >&2 echo "timer_start $timer_start_at $timer_start_atms"
}

function timer_print_ms() {
    _now=$(($(timer_date "+%s%N")/1000000))
    _time=$((_now-timer_start_atms))
    echo $_time
}

function timer_print() {
    _now=$(timer_date "+%s")
    _time=$((_now-timer_start_at))
    _minute=$((_time/60))
    _second=$((_time-_minute*60))
    echo $_time
}

function timer_clean() {
    timer_start_at=''
}
