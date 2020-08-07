#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

fast_mode=1

branch_name=

GIT_BIN=/usr/bin/git
GIT_MULTI=$ROOT/git.multi.sh

function git() {
    # echo "run git $@"
    $GIT_BIN $@
}

function remotes() {
    test_if_repo
    git remote -v|awk '{print $1}'|uniq|grep -v '^manual_'
}

function branch() {
    test_if_repo
    branch_name=`git branch -a|grep '^*'|awk '{print $2}'` && pass=1
    test_if_pass "get branch [$branch_name]"
}

function test_if_repo() {
    git status --porcelain > /dev/null 2>&1 && pass=1
    test_if_pass "" "no git repository found"
}

function get_unstaged() {
    git status -s|wc -l|awk '{print $1}'
}

function test_if_staged() {
    test_if_repo
    count=`get_unstaged`
    if [ $count -gt 0 ]; then
        cfont -red
        echo "you have unstaged changes $count"
        cfont -reset
        exit 1
    fi    
}

if [ "$1" == "coloroff" ]; then
    cfont_off=1
    shift
fi

cmd=$1
case $1 in
    'all' )
        shift
        # cfont "run" -yellow " $GIT_MULTI $@" -reset
        $GIT_MULTI $@ *
        exit 0
    ;;
    'each' )
        shift
        $GIT_MULTI $@
        exit 0
    ;;
    'sync' )
        branch
        shift
        upstream=upstream
        if [ $# -eq 1 ]; then 
            upstream=$1
            shift
        fi
        if test `git remote|grep $upstream|wc -l` -eq 0; then
            cfont -red "fetch remote [$upstream] no found" -reset -n
            exit 1
        fi
        cfont -yellow "fetching upstream changes" -reset -n
        git fetch $upstream
        branch=$branch_name
        echo
        cfont -yellow "sync with local branch" -green $branch "<- $upstream/$branch" -reset -n
        git merge $upstream/$branch
        exit 0 
    ;;
    'xpush' | 'upush' | 'tpush' )
        # test_if_staged
        branch
        shift
        remotes|while read remote; do
            if [ "$remote" == "upstream" ];then
                cfont -dim "ignore upstream" -n -reset
                continue
            fi
            cfont -yellow
            cfont -reset
            push_arg=
            if [ "$cmd" == "upush" -a "$remote" == "origin" ]; then
                push_arg="-u"
            fi
            if [ "$cmd" == "tpush" ]; then
                push_arg="$push_arg --tags"
            fi
            if [ $# -gt 0 ]; then
                push_arg="$push_arg $@"
            fi
            echo "git push $push_arg $remote $branch_name..."
            git push $push_arg $remote $branch_name && pass=1
            test_if_pass "push $remote $branch_name" "when pushing $branch_name to $remote"
        done
        exit 0
    ;;
    'xpull' )
        test_if_staged
        branch
        remote=origin
        if [ "$2" != "" ]; then
            remote=$2
        fi
        cfont -yellow
        echo "pulling $branch_name from $remote..."
        cfont -reset
        git pull $remote $branch_name && pass=1
        test_if_pass "pull $remote $branch_name" "when pulling $branch_name from $remote"
        exit 0
    ;;
    'commit-all' | 'ca' )
        if [ "`get_unstaged`" == "0" ]; then
            exit 2
        fi
        set -e
        git add . -A
        git commit -a 
        if [ "$(ls .git/svn 2>/dev/null)" != "" ]; then
            git svn rebase
            git svn dcommit 
        fi
        exit 0
    ;;
    'checkout' )
        test_if_repo
        if [ "$2" == "." ] || [ "$2" == "" ] || [ "$2" == "./" ]; then
            cfont "using" -red " 'git checkout .'" -reset " is very dangerous, please use " -green "'$GIT_BIN checkout .'" -reset " if confirmed" -n
            exit 1
        fi
    ;;
    'remotes' )
        remotes
        exit 0
    ;;
    'p' | 'print' | 'print_changed' | 'pc' )
        shift
        pwd=`pwd`
        if [ -d .git ]; then
            test_if_staged
            exit 0
        fi
        ls -l|grep "^\(d\|l\)"|awk '{print $9}'|while read name; do
            cd $pwd
            test ! -d $name/.git && continue
            test_in_list $name .gitignore && continue
            cd $pwd
            cd $name
            repo=0
            git status > /dev/null 2>&1 && repo=1
            test $repo -eq 0 && continue
            # echo "checking folder $name `get_unstaged`" && continue
            # get_unstaged && continue
            unstaged=`get_unstaged`
            cfont -gray
            if [ "$cmd" == "print_changed" -o "$cmd" == "pc" ]; then
                 if [ $unstaged -eq 0 ]; then
                    continue
                 fi
            fi
            test $unstaged -gt 0 && cfont -red
            echo "$name ... "$unstaged
            cfont -reset
        done
        exit 0
    ;;
    'retag' )
        test_if_staged
        branch
        shift
        tag=$1
        if [ "$tag" == "" ]; then
            echo "usage $0 retag [tag_name]" && exit 1
        fi
        shift
        $GIT_BIN fetch origin || exit 1
        $GIT_BIN tag -d $tag
        $GIT_BIN tag -a $tag -m "add tag/$tag"
        remotes|while read remote; do
            if [ "$remote" == "upstream" ];then
                cfont -dim "ignore upstream" -n -reset
                continue
            fi
            echo "git push $remote $tag -f..."
            $GIT_BIN push $remote $tag -f && pass=1
            test_if_pass "push tag/$tag to $remote" "when pushing tag/$tag to $remote"       
        done
        exit 0
    ;;
    'l' )
        $GIT_BIN log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --
        exit 0
    ;;
    'rtag' )
        test_if_staged
        rtag=`echo r$(date +%Y%m%d%H%M%S)`
        $GIT_BIN tag $rtag
        echo $rtag
        exit 0
    ;;
esac

$GIT_BIN "$@"


