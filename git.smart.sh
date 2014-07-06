#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

fast_mode=1

branch_name=

GIT_BIN=/usr/bin/git

function git() {
    # echo "run git $@"
    $GIT_BIN $@
}

function remotes() {
    test_if_repo
    git remote -v|awk '{print $1}'|uniq
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

case $1 in
    'xpush' )
        test_if_staged
        branch
        remotes|while read remote; do
            cfont -yellow
            echo "git push $remote $branch_name..."
            cfont -reset
            git push $remote $branch_name && pass=1
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
        git add .
        git commit -a
        exit 0
    ;;
    'checkout' )
        test_if_repo
        if [ "$2" == "." ]; then
            cfont "using" -red " 'git checkout .'" -reset " is very dangerous, please use " -green "'$GIT_BIN checkout .'" -reset " if confirned"
            exit 1
        fi
    ;;
    'remotes' )
        remotes
        exit 0
    ;;
    'p' | 'print' )
        shift
        pwd=`pwd`
        ls -l|grep ^d|awk '{print $9}'|while read name; do
            cd $pwd
            test ! -d $name && continue
            cd $pwd
            cd $name
            repo=0
            git status > /dev/null 2>&1 && repo=1
            test $repo -eq 0 && continue
            # echo "checking folder $name" && continue
            # get_unstaged && continue
            unstaged=`get_unstaged`
            cfont -dim
            test $unstaged -gt 0 && cfont -red            
            echo "$name ... "$unstaged
            cfont -reset
        done
        exit 0
    ;;
    'l' )
        $GIT_BIN log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --
        exit 0
    ;;
esac

$GIT_BIN "$@"
