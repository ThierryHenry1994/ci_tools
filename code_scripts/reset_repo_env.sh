#!/bin/bash -ex

############ Required Params in param config file #############
# IN_WORKSPACE
###############################################################

reset_repo_env()
{
	local pre_dir=$(pwd)
	if [[ -d ${IN_WORKSPACE}/.repo ]]; then
		cd ${IN_WORKSPACE}
		repo forall -v -c bash -c "git reset --hard && git clean -fd"
	fi
	cd ${pre_dir}
}

reset_repo_env