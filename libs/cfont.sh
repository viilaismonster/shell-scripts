cfont_off=0
function cfont_print {
    if [ $cfont_off -ne 0 ]; then
        return
    fi
    echo $@
}
function cecho {
    cfont $@ -reset -n
}
function cfont {
    while (($#!=0))
    do
        case $1 in
                -b)
                        echo -ne " ";
                ;;
                -t)
                        echo -ne "\t";
                ;;
                -n)     echo -ne "\n";
                ;;
                -black|-dim)
                        cfont_print -ne "\033[30m";
                ;;
                -red)
                        cfont_print -ne "\033[31m";
                ;;
                -green)
                        cfont_print -ne "\033[32m";
                ;;
                -yellow)
                        cfont_print -ne "\033[33m";
                ;;
                -blue)
                        cfont_print -ne "\033[34m";
                ;;
                -purple)
                        cfont_print -ne "\033[35m";
                ;;
                -cyan)
                        cfont_print -ne "\033[36m";
                ;;
                -white|-gray) cfont_print -ne "\033[37m";
                ;;
                -reset)
                        cfont_print -ne "\033[0m";
                ;;
                *)
                echo -ne "$1"
                ;;
        esac
        shift
    done
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
