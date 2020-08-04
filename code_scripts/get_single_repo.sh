#!/bin/bash -e

############ Required Params in param config file #############
# IN_WORKSPACE
# IN_REPO_URL
# IN_BRANCH_NAME
###############################################################

init_env()
{
	local pre_dir=$(pwd)
	if [[ -d ${IN_WORKSPACE} ]];then
		cd ${IN_WORKSPACE}
		git clean -fdx
		git reset --hard HEAD
		git pull
	else
		git clone ${IN_REPO_URL} -b ${IN_BRANCH_NAME} ${IN_WORKSPACE}
	fi
	cd ${pre_dir}
}

init_env
