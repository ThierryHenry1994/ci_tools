#!/bin/bash

############ Required Params in param config file #############
# IN_WORKSPACE
###############################################################


# RETURN CODE
RETURN_OK=0
RETURN_FAIL=1

# EXIT CODE
EXIT_OK=0
EXIT_VAR_NULL=3
EXIT_FILE_NO_EXIST=4
EXIT_DIR_NO_EXIST=5

# LOG_LEVEL
LOG_ERROR=1
LOG_WARNING=2
LOG_DEBUG=3

LOG_LEVEL=${LOG_LEVEL:-${LOG_ERROR}}

###############################################################################
#    Function: get_current_set_option
#        Args:
#       Usage: get_current_set_option
# Description: Get currnet set options.In loops functions,need get it first,then set +e and set it back in the end
###############################################################################
function get_current_set_option()
{
    case $- in
        *e*) set_option="-e" ;;
        *)  set_option="+e" ;;
    esac
}

hide_log_exec()
{
	get_current_set_option
	set +e
	echo -e "\nexecute cmd: $1 \n">>$IN_WORKSPACE/hide_exec_log.log
	$1 &>$IN_WORKSPACE/hide_exec_log.log

	exec_result=$?

    if [[ $exec_result != 0 ]];then
        cat $IN_WORKSPACE/hide_exec_log.log
        set +x
        echo "####################################";
        echo "#  ERROR: Failed when exec $1       #";
        echo "####################################";
        set -x
        exit 1
    fi
    set ${set_option}
}

###############################################################################
#    Function: error
#        Args: $1: LC_MESSAGE
#       Usage: error "this is a error log message."
# Description: print error level log to stdout
###############################################################################
function error()
{
    local LC_MESSAGE=$1

    if [ ${LOG_LEVEL} -ge ${LOG_ERROR} ]
    then
        echo "***error: in function ${FUNCNAME[1]}"
        echo "   ${LC_MESSAGE}"
    fi
}


###############################################################################
#    Function: warning
#        Args: $1: LC_MESSAGE
#       Usage: warning "this is a warning log message."
# Description: print warning level log to stdout
###############################################################################
function warning()
{
    local LC_MESSAGE=$1

    if [ ${LOG_LEVEL} -ge ${LOG_WARNING} ]
    then
        echo "***warning: in function ${FUNCNAME[1]}"
        echo "   ${LC_MESSAGE}"
    fi
}


###############################################################################
#    Function: debug
#        Args: $1: LC_MESSAGE
#       Usage: debug "this is a debug log message."
# Description: print debug level log to stdout
###############################################################################
function debug()
{
    local LC_MESSAGE=$1

    if [ ${LOG_LEVEL} -ge ${LOG_DEBUG} ]
    then
        echo "***debug: in function ${FUNCNAME[1]}"
        echo "   ${LC_MESSAGE}"
    fi
}


###############################################################################
#    Function: loop_exec_command_n
#        Args: $1: times $2: command
#       Usage: loop_exec_command_n n "make" ("n" is a number that is not less than 1)
# Description: loop exec command util success by "n" times
###############################################################################
function loop_exec_command_n()
{
    local loop_num=$1
    local icommand=$2

    if [[ ! $loop_num =~ ^[0-9]+$ || $loop_num -lt 1 ]]
    then
        error "loop_num is not a number or less than 1, please check function argument $@"
        exit 1
    fi

    if [[ -z ${icommand} ]]
    then
        error "icommand is null, please check function argument $@"
        exit 1
    fi

    get_current_set_option
    set +e
    for i in $(seq 1 ${loop_num})
    do
        time ${icommand}
        if [ $? -eq 0 ]
        then
            debug "loop_exec_command_n $loop_num \"${icommand}\" for $i times done."
            set ${set_option}
            return ${RETURN_OK}
        else
            error "loop_exec_command_n $loop_num \"${icommand}\" for $i times failed."
            sleep 10s
        fi
    done

    exit 1
}


