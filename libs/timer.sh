
timer_start_at=''

function timer_start() {
    timer_start_at=$(date "+%s")
}

function timer_print() {
    _now=$(date "+%s")
    _time=$((_now-timer_start_at))
    _minute=$((_time/60))
    _second=$((_time-_minute*60))
    echo $_time
}

function timer_clean() {
    timer_start_at=''
}
