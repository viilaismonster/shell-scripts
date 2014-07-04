#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

fast_mode=1

branch_name=

function remotes() {
    git remote -v|awk '{print $1}'|uniq
}

function branch() {
    branch_name=`git branch -a|grep '^*'|awk '{print $2}'` && pass=1
    test_if_pass "get branch [$branch_name]"
}

function test_if_staged() {
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
            echo "pushing to $remote..."
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
        if [ "$2" == "." ]; then
            echo "using 'gg checkout .' is very dangerous, please use 'git checkout .' if confirmed"
            exit 1
        fi
    ;;
    'remotes' )
        remotes
        exit 0
    ;;
esac

git $@
