#!/bin/bash -ex

############ Required Params in param config file #############
# IN_WORKSPACE
# IN_LUNCH_NAME
# IN_BUILD_COMMAND
###############################################################

############ Optional Params in param config file #############
# IN_PRE_BUILD_COMMAND
# IN_PROJ_CCACHE_PROFILE
###############################################################

source ${PB_SCRIPT_PATH}/common_tools/common_functions.sh

set_ccache_profile()
{
    # use config file to set ccache for k8s
    if  [[ -f $IN_PROJ_CCACHE_PROFILE ]];then
        mkdir -p ${HOME}/bin
        ln -sf /usr/local/bin/ccache ${HOME}/bin/gcc
        ln -sf /usr/local/bin/ccache ${HOME}/bin/g++
        ln -sf /usr/local/bin/ccache ${HOME}/bin/cc
        ln -sf /usr/local/bin/ccache ${HOME}/bin/c++
        export PATH="${HOME}/bin:${PATH}"
        source $IN_PROJ_CCACHE_PROFILE
        ccache -s
    fi
}

build_env()
{
	local pre_dir=$(pwd)
	cd ${IN_WORKSPACE}
	source build/envsetup.sh
	lunch $IN_LUNCH_NAME
	set_ccache_profile

	if [[ x"${IN_PRE_BUILD_COMMAND}" != x"" ]]; then
		hide_log_exec "${IN_PRE_BUILD_COMMAND}"
	fi

	hide_log_exec "${IN_BUILD_COMMAND}"
	cd ${pre_dir}
}

build_env