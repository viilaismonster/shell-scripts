#!/bin/bash

ROOT=~/tool/shell-scripts
. $ROOT/libs/common.sh

import multi

flag=~/.maven.smart.flags
flag_notest="-Dmaven.test.skip=true"
fast_mode=1
MVN_BIN=/usr/local/bin/mvn
multi_cmd_status=maven_print

touch $flag
function mvn_bin {
    flag_on=
    cat $flag|grep "^on maven.test.skip" && flag_on="$flag_on $flag_notest"
    $MVN_BIN $flag_on $@
}

function verify_fname {
    case "$1" in
        maven.test.skip ) ;;
        * ) cfont "unknown mavne flag" -red $1 -reset -n ;
    esac
}

function is_maven_folder {
    test -d $1 && test -f $1/pom.xml
    return $?
}

function maven_run {
    enter_folder_run mvn_bin $@
}

function maven_clean {
    maven_run clean $@
    return $?
}

function maven_compile { 
    maven_run compile $@
    return $? 
}
function maven_install { 
    maven_run install $@
    return $? 
}
function maven_deploy { 
    maven_run deploy $@
    return $? 
}
function maven_package { 
    maven_run package $@
    return $? 
}

function maven_enter_folder_print { 
    enter_folder_run maven_print "@" $@
    return $? 
}
multi_cmd_status=maven_print
function maven_print {
    groupId=?
    artifactId=?
    version=?
    r1='<groupId>(.*)</groupId>.*'
    r2='<artifactId>(.*)</artifactId>.*'
    r3='<version>(.*)</version>.*'
    rdependencies='<dependencies>'
    rparent='<parent>'
    rend='</project>'
    count=`cat pom.xml | grep '<groupId\|<artifactId\|<version'|wc -l|awk '{print $1}'`
    if [ $count -eq 0 ]; then
        echo '?'
        return
    fi
    if [ $count -gt 3 ]; then
        count=3
    fi
    cat pom.xml | grep '<groupId\|<artifactId\|<version\|<parent\|<dependencies\|</project>' | while read line; do
        [[ "$line" =~ $rparent ]] && count=$(($count+3))
        [[ "$line" =~ $r1 ]] && groupId=${BASH_REMATCH[1]} && count=$(($count-1))
        [[ "$line" =~ $r2 ]] && artifactId=${BASH_REMATCH[1]} && count=$(($count-1))
        [[ "$line" =~ $r3 ]] && version=${BASH_REMATCH[1]} && count=$(($count-1))
        # >&2 echo $count" $artifactId "$line
        [[ "$line" =~ $rdependencies ]] && count=0
        [[ "$line" =~ $rend ]] && count=0
        if [ $count -eq 0 ]; then
            echo [$groupId:$artifactId:$version]
            return
        fi
    done

}

function mvn_multi {
    cmd=$1
    shift
    case $cmd in
        'clean' | 'compile' | 'install' | 'deploy' | 'package' )
            loop_folder is_maven_folder maven_$cmd $@
        ;;
        'p' | 'print' )
            loop_folder is_maven_folder maven_enter_folder_print $@
        ;;
        * )
            cfont unknown maven multi command -red $cmd -reset
        ;;
    esac 
}

case "$1" in
    "each" )
        shift
        mvn_multi $@    
    ;;
    "all" )
        shift
        mvn_multi $@ *
    ;;
    "flag" | "flags" )
        shift
        if [ $# -eq 1 ]; then
            verify_fname $1
            cat $flag | grep $1
        elif [ $# -eq 2 ]; then
            fname=$1
            verify_fname $fname
            shift
            case $1 in
                off ) 
                    cat $flag|grep -v "^on $fname" > $flag 
                    cfont -red "disable" -reset "mvn flag" -yellow "$fname" -reset -n
                    ;;
                on ) 
                    cat $flag|grep -v $fname > $flag; echo "on $fname" >> $flag
                    cfont -green "enable" -reset "mvn flag" -yellow "$fname" -reset -n
                    ;;
                * )
                    cfont -red "unexpected flag option, neither on nor off" -reset -n 
                    ;;
            esac
        else
            if [ $# -ne 0 ]; then
                cfont -yellow "mvn flag command" -red "need 0/1/2 args" -reset -n
            fi
            cat $flag
        fi
    ;;
    * )
        mvn_bin $@
        # $MVN_BIN $@
    ;;
esac



