#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh
ERR=/tmp/git_multi_err
COMMENT=/tmp/git_multi_comment
XGIT=$ROOT/git.smart.sh
fast_mode=1

function is_git_folder() {
    if [ ! -d $1 ]; then
        return 1
    fi
    if  [ ! -d $1/.git ]; then
        return 1
    fi
    return 0
}

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
    str=$1"                                                       "
    echo "${str:0:$len}"
}

function loop_folder() {
    folder_test=$1; shift
    cmd=$1; shift
    cfont "foreach " -green "$# " -reset
    cfont "looping " -green "@$folder_test " -reset 
    cfont "run " -green "$cmd" -reset -n
    echo
    while test $# -gt 0; do
        folder=$1
        shift
        $folder_test $folder
        if [ $? -ne 0 ]; then 
            continue
        fi
        cfont "$cmd >" -yellow " `str_fix 30 $folder` \t" -reset "..."
        $cmd $folder 1>$ERR 2>&1
        # $cmd $folder
        case $? in
            0 )
                cfont -green " [ok]" -reset -n
            ;;
            2 )
                cfont -dim " [ignore]" -reset -n
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

function clone() {
    is_git_folder $2
    if [ $? -eq 0 ]; then
        return 2
    fi
    git clone $1/$2.git
}

function enter_folder_git() {
    cd $2
    $XGIT $1
    ret=$?
    cd -
    return $ret
}

function enter_folder_git_xpush() { 
    enter_folder_git xpush $@ 
    return $?
}
function enter_folder_git_xpull() { 
    enter_folder_git xpull $@ 
    return $?
}
function enter_folder_git_ca() { 
    enter_folder_git ca $@ 
    return $?
}

function enter_folder_commit() {
    cd $1
    if [ "`get_unstaged`" == "0" ]; then
        cd -
        return 2
    fi
    git add . -A
    git commit --file=$COMMENT
    cd -
}

function get_unstaged() {
    git status -s|wc -l|awk '{print $1}'
}

cmd=$1
shift
case $cmd in
    'xpush' | 'xpull' | 'ca' )
        loop_folder is_git_folder "enter_folder_git_$cmd" $@
    ;;
    'commit' )
        echo "" > $COMMENT
        echo "# git all commit" >> $COMMENT
        echo "# $@" >> $COMMENT
        echo "# " >> $COMMENT
        $XGIT coloroff pc | awk -F '#' '{print "# "$1}' >> $COMMENT
        echo "# " >> $COMMENT
        vi $COMMENT
        loop_folder is_git_folder "enter_folder_commit" $@
    ;;
    'clone' )
        remote=$1
        shift
        cfont "use remote " -green "$remote" -reset -n
        loop_folder folder_or_not_exist "clone $remote" $@
    ;;
    * )
        cfont "$cmd" -red " not a multi command" -reset -n
    ;;
esac


