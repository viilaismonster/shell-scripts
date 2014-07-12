shell-scripts(ss) contains several build in libs

how-to
======

> $ import LIB_NAME

> $ import_once LIB_NAME


### common.sh ###

libs entrance script

> ROOT=~/tool/shell-scripts

>  . $ROOT/libs/common.sh


### cfont.sh ###

use color in console output

> cfont --reset

> cfont --red|green|yellow|blue|purple|cyan

> cfont --black|dim|white|gray


### timer.sh ###

> timer_start

> timer_print

> cost=\`timer_print\`

> timer_clean


### booter.sh ###

> booter_config -n PROGRESS_NAME [--background|--console|-m MODE] BOOTER_COMMAND

> booter_stop

> booter_start