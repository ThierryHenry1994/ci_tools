#!/bin/bash -e

export PB_SCRIPT_PATH=$(cd $(dirname $0); pwd)
PB_SCRIPT_NAME=$(basename $0)
PB_PARAM_CFG=
PB_SCRIPT_CFG=
PB_SCRIPT_URL=
PB_SCRIPT_VERSION=
export PB_CI_PARAMS_CFG_TMP=/tmp/ci_tmp_param_cfg.cfg

function usage(){
cat <<EOF
                -- ${PB_SCRIPT_NAME} Usage --
Usage: ${BASH_SOURCE} [option] [args]

Options:
    --param_cfg [arg]: Specify the params config file
    --script_cfg [arg]: Specify the script config file
    -h      : show this usage message and exit
EOF

}


###############################################################################
#   Begin to work
###############################################################################
#Parse options
TEMP=$(getopt -l help,param_cfg:,script_cfg: -n $0 -- $@)
if [ $? -ne 0 ]
then
    echo "***error: in file ${BASH_SOURCE}"
    echo "   No option matched, please check up."
    exit 1
fi
# eval set -- "$TEMP"

while [ -n "$1"  ]
do
    case "$1" in
        --param_cfg) PB_PARAM_CFG="$2";
            shift 2;
            continue;;
        --script_cfg) PB_SCRIPT_CFG="$2";
            shift 2;
            continue;;
        --help) usage
            shift;
            exit 0;;
        *)
            echo "***error:"
            echo "   No option: $1"
            usage
            exit 1;;
    esac
done


function get_repo_version()
{
	PB_SCRIPT_URL=$(cd ${PB_SCRIPT_PATH};git remote get-url --push $(git remote))
	PB_SCRIPT_VERSION=$(cd ${PB_SCRIPT_PATH};git log --pretty=%H -1)
}

function save_run_info()
{
	get_repo_version
	echo "###################### script run info begin ######################"
	echo "[script repo info]"
	echo "url:${PB_SCRIPT_URL}"
	echo "version:${PB_SCRIPT_VERSION}"
	echo ""
	echo "[PARAM_CFG]"
	cat ${PB_PARAM_CFG}
	echo ""
	echo "[FUNC_CFG]"
	cat ${PB_SCRIPT_CFG}
	echo "###################### script run info end #########################"
	echo ""
}

function main()
{
	rm -rf $PB_CI_PARAMS_CFG_TMP
	save_run_info | tee $(pwd)/current_run_info.log
	export PB_CURRENT_RUN_INFO=$(pwd)/current_run_info.log

	if [ -f ${PARAM_CFG} ];then
		while read line
		do
			if [[ $line == "" ]] || [[ $line =~ ^# ]]; then
				continue
			fi

			if [[ ! $line =~ ^IN_ ]];then
				echo "$line not match the rule:Params name in ${PB_PARAM_CFG} must start with IN_."
				exit 1
			fi
			eval export $line
		done < ${PB_PARAM_CFG}
	fi

	if [ -f ${PB_SCRIPT_CFG} ];then
		while read line
		do
			if [[ $line == "" ]] || [[ $line =~ ^# ]]; then
				continue
			fi

			script_name=`echo $line | awk '{print $1}'`
			input_cfg=`echo $line | awk '{if($2~/input/){print $2}else if($3~/input/){print $3}}'`
			# IN_PARAMS_CFG=$(echo ${input_cfg} | cut -d ":" -f 2)
			if [[ -n "$input_cfg" && -f $PB_CI_PARAMS_CFG_TMP ]];then
				# echo "IN_PARAMS_CFG:$PB_CI_PARAMS_CFG_TMP"
				while read line
				do
					if [[ ! $line =~ ^CI_ ]];then
						echo "$line not match the rule:Params name in ${PB_SCRIPT_CFG} must start with CI_."
						exit 1
					fi
					eval export $line
				done < $PB_CI_PARAMS_CFG_TMP
			fi

			# output_cfg=`echo $line | awk '{if($2~/output/){print $2}else if($3~/output/){print $3}}'`
			# export OUT_PARAMS_CFG=$(echo ${output_cfg} | cut -d ":" -f 2)
			${PB_SCRIPT_PATH}/${script_name}
		done < ${PB_SCRIPT_CFG}
	fi
}

main