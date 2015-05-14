cfont_off=0
cfont_sh_echo=`echo -ne|wc -c|awk '{print $1}'`

function cfont_print {
    if [ $cfont_off -ne 0 ]; then
        return
    fi
    case $cfont_sh_echo in
        0 )
            echo $@
        ;;
        * )
            if [[ $# -eq 2 ]]; then
                shift
            fi
            echo $@
        ;;
    esac
}
function cecho {
    if [[ $cfont_sh_echo -ne 0 ]]; then
        cfont $@ -reset
    fi
    if [[ $cfont_sh_echo -eq 0 ]]; then
        cfont $@ -reset -n
    fi
}
function cfont {
    line=""
    insert_blank=0
    while (($#!=0))
    do
        case $1 in
                -b)
                        line+=" "
                ;;
                -t)
                        line+="\t"
                ;;
                -n)     
                        line+="\n"
                        insert_blank=0
                ;;
                -black|-dim)
                        line+=`cfont_print -ne "\033[30m"`
                ;;
                -red)
                        line+=`cfont_print -ne "\033[31m"`
                ;;
                -green)
                        line+=`cfont_print -ne "\033[32m"`
                ;;
                -yellow)
                        line+=`cfont_print -ne "\033[33m"`
                ;;
                -blue)
                        line+=`cfont_print -ne "\033[34m"`
                ;;
                -purple)
                        line+=`cfont_print -ne "\033[35m"`
                ;;
                -cyan)
                        line+=`cfont_print -ne "\033[36m"`
                ;;
                -white|-gray) 
                        line+=`cfont_print -ne "\033[37m"`
                ;;
                -reset)
                        line+=`cfont_print -ne "\033[0m"`
                ;;
                *)
                    if [[ $insert_blank -ne 0 ]]; then
                        line+=" "
                    fi
                    line+=$1
                    insert_blank=1
                ;;
        esac
        shift
    done
    if [[ $cfont_sh_echo -ne 0 ]]; then
        echo $line
    fi
    if [[ $cfont_sh_echo -eq 0 ]]; then
        echo -ne $line
    fi
}

function cfont_test() {
    T='#@#' # The test text

    echo
    echo "        default 40m     41m     42m     43m     44m     45m     46m
    47m"
    ## FGs 为前景(foreground)色, BG 为背景(background)色
    for FGs in '    m' '   1m' ' 30m' '1;30m' ' 31m' '1;31m' ' 32m' '1;32m' '
    33m' '1;33m' ' 34m' '1;34m' ' 35m' '1;35m' ' 36m' '1;36m' ' 37m' '1;37m'
            do
            FG=$(echo $FGs|tr -d ' ')
            echo -en " $FGs \033[$FG $T "
            for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
                    do
                    echo -en " \033[$FG\033[$BG $T  \033[0m"
            done
            echo
    done
    echo

}
