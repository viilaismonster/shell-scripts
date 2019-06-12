#!/bin/bash
ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

COMMENT=/tmp/git_multi_comment
XGIT=$ROOT/git.smart.sh
fast_mode=1

import multi
multi_tmp_err=/tmp/git_multi_err

function is_git_folder() {
    if [ ! -d $1 ]; then
        return 1
    fi
    if  [ ! -d $1/.git ]; then
        return 1
    fi
    return 0
}

function clone() {
    is_git_folder $2
    if [ $? -eq 0 ]; then
        return 2
    fi
    git clone $1/$2.git
    return $?
}

multi_cmd_status=cmd_status
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
            echo `get_unstaged` "files"
        ;;
        'enter_folder_git_xpull' | 'enter_folder_git_show' )
            remotes_count=0
            remotes_count=`$XGIT remotes|wc -l|awk '{print $1}'`
            if [ $remotes_count -gt 1 ]; then
                git remote update origin >/dev/null 2>&1
            elif [ $remotes_count -eq 1 ]; then
                git remote update >/dev/null 2>&1
            fi
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

function enter_folder_git() {
    # trap_return=
    # trap "trap_return=3" INT
    enter_folder_run $XGIT $@
    ret=$?
    # if [ "$trap_return" != "" ]; then return $trap_return; fi
    return $ret
}

function enter_folder_git_xpush() { 
    cd $1
    if [ `git status --porcelain --branch|grep "\.\.\."|wc -l` -eq 0 ]; then
        echo "upstream no found"
        return 1
    fi
    status=`git status --porcelain --branch|grep ahead|wc -l|awk '{print $1}'` > /dev/null
    ret=$?
    cd - > /dev/null
    if [ $ret -ne 0 ]; then
        return 1
    fi
    if [ "$status" == "0" ]; then
        return 2
    fi
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
function enter_folder_git_show() { 
    return 0
}

function enter_folder_commit() {
    cd $1
    if [ "`get_unstaged`" == "0" ] || [ -d .git/svn ]; then
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
    'xpush' | 'upush' | 'xpull' | 'show' )
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


