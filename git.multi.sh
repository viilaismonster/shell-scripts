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
        cfont "`cmd_brief $cmd` >" -yellow " `str_fix 30 $folder` \t" -reset "..."
        status=`enter_folder_run 'cmd_status' $cmd $folder`
        $cmd $folder 1>$ERR 2>&1
        # $cmd $folder
        case $? in
            0 )
                cfont -green " [ok]" -dim " $status" -reset -n
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

function cmd_status() {
    # echo "run cmd_status for $1 in `pwd`"
    case $1 in
        # 'enter_folder_git_xpush' )
        #     echo `git log --oneline origin..HEAD | wc -l` "commits"
        # ;;
        # 'enter_folder_git_xpull' )
        #     echo `git log --oneline HEAD..origin | wc -l` "commits"
        # ;;
        'enter_folder_commit' )
            echo `get_unstaged` "changes"
        ;;
        'enter_folder_git_xpull' )
            git remote update >/dev/null 2>&1
            git status --porcelain --branch
        ;;
        * )
            git status --porcelain --branch
        ;;
    esac
}

function cmd_brief() {
    case $1 in
        'enter_folder_git_xpush' )
            echo 'xpush'
        ;;
        'enter_folder_git_xpull' )
            echo 'xpull'
        ;;
        'enter_folder_git_upush' )
            echo 'upush'
        ;;
        'enter_folder_commit' )
            echo 'commit'
        ;;
        * )
            echo $1
        ;;
    esac
}

function enter_folder_run() {
    # echo "enter folder $3 run $1 with args $2"
    cd $3
    $1 $2
    ret=$?
    cd - > /dev/null
    return $ret
}

function enter_folder_git() {
    enter_folder_run $XGIT $@
    return $?
}

function enter_folder_git_xpush() { 
    enter_folder_git xpush $@ 
    return $?
}
function enter_folder_git_upush() { 
    enter_folder_git upush $@ 
    return $?
}
function enter_folder_git_xpull() { 
    enter_folder_git xpull $@ 
    return $?
}

function enter_folder_commit() {
    cd $1
    if [ "`get_unstaged`" == "0" ]; then
        cd -
        return 2
    fi
    git add . -A
    git commit --file=$COMMENT.trim
    cd -
}

function get_unstaged() {
    git status -s|wc -l|awk '{print $1}'
}

cmd=$1
shift
case $cmd in
    'xpush' | 'upush' | 'xpull' )
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
        cat $COMMENT | grep -v ^# | grep -v "^ *$" > $COMMENT.trim
        line_count=`cat $COMMENT.trim | wc -l | awk '{print $1}'`
        if [ "$line_count" == "0" ]; then
            >&2 cfont -red "commit more than 1 line!" -reset -n
            exit 1
        fi
        echo
        echo "committing..."
        echo
        cfont -yellow
        cat $COMMENT.trim
        cfont -reset
        echo
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


