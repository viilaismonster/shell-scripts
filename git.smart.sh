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
    git status --porcelain > /dev/null && pass=1
    test_if_pass "" "no git repository found"
}

function test_if_staged() {
    test_if_repo
    count=`git status -s|wc -l|awk '{print $1}'` && pass=1
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
            echo "git push $remote $branch_name..."
            git push $remote $branch_name && pass=1
            test_if_pass "" "when pushing $branch_name to $remote"
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
        echo "pulling $branch_name from $remote..."
        git pull origin $branch_name && pass=1
        test_if_pass "" "when pulling $branch_name from $remote"
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
            echo "using 'git checkout .' is very dangerous, please use '$GIT_BIN checkout .' if confirmed"
            exit 1
        fi
    ;;
    'remotes' )
        remotes
        exit 0
    ;;
esac

git $@
