multi_cmd_status=
multi_tmp_err=/tmp/multi_err

function folder_or_not_exist() {
    if [ ! -e $1 ]; then
        return 0
    fi
    if [ -d $1 ]; then
        return 0
    fi
    return 1
}

function str_fix() {
    len=$1
    shift
    str=$1
    str+=" _________________________________________________"
    echo "${str:0:$len}"
}

function multi_cmd_brief() {
    type cmd_brief > /dev/null 2>&1
    ret=$?
    if [ $ret -eq 0 ]; then
        cmd_brief $@
    else
        echo $@
    fi
}

function loop_folder() {
    ERR=$multi_tmp_err
    folder_test=$1; shift
    cmd=$1; shift
    cfont "foreach " -green "$# " -reset
    cfont "filter " -green "@$folder_test " -reset
    cfont "run " -green "$cmd" -reset -n
    echo
    while test $# -gt 0; do
        folder=$1
        shift
        $folder_test $folder
        if [ $? -ne 0 ]; then
            continue
        fi
        cfont "`multi_cmd_brief $cmd` >" -yellow " `str_fix 36 $folder` \t." -reset "..."
        ret=
        trap "ret=3" INT
        if [ "$multi_cmd_status" != "" ]; then
            status_str=`enter_folder_run "$multi_cmd_status" $cmd $folder`
        else
            status_str=
        fi
        if [ "$ret" == "" ]; then
            $cmd $folder 1>$ERR 2>&1
            ret=$?
            # $cmd $folder
        fi
        case $ret in
            0 )
                cfont -green " [ok]" -dim " $status_str" -reset -n
            ;;
            2 )
                cfont -dim " [ignore]" -reset -n
            ;;
            3 )
                cfont -dim " [cancel]" -reset -n
            ;;
            1 | *)
                cfont -red " [error]" -reset -n
                cat $ERR
                cfont -n
            ;;
        esac
    done
    echo
}

function enter_folder_run() {
    if [ ! -d $3 ]; then
        return 1
    fi
    trap_return=
    trap "trap_return=3" INT
    # echo "enter folder $3 run $1 with args $2"
    cd $3
    $1 $2
    ret=$?
    cd - > /dev/null
    if [ "$trap_return" != "" ]; then return $trap_return; fi
    return $ret
}
