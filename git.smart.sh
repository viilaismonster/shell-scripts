#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

branch_name=

function remotes() {
    git remote -v|awk '{print $1}'|uniq
}

function branch() {
    branch_name=`git branch -a|grep '^*'|awk '{print $2}'` && pass=1
    test_if_pass "get branch $branch_name"
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
            git push $remote $branch_name && pass=1
            test_if_pass "push $branch_name to $remote"
        done
        exit 0
    ;;
    'xpull' )
        test_if_staged
        branch
        git pull origin $branch_name
        exit 0
    ;;
    'commit-all' | 'ca' )
        git add .
        git commit -a
        exit 0
    ;;
    'remotes' )
        remotes
        exit 0
    ;;
esac

git $@
