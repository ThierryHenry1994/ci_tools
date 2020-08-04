#!/bin/bash -ex

############ Required Params in param config file #############
# IN_JK_PROJECT
# IN_RELEASE_BRANCH
# IN_PROJECT_CONFIG_DIR

###############################################################

############ Optional Params in param config file #############
###############################################################

# CI_RELEASE_MIDDLE_DIR 为其他脚本的输出变量

source ${PB_SCRIPT_PATH}/common_tools/common_functions.sh
source ${IN_PROJECT_CONFIG_DIR}/${IN_JK_PROJECT}/release.cfg

function upload_release()
{
    if [ -z "$CFG_UPLOAD_DIR_PRE" ];then
        echo "CFG_UPLOAD_DIR_PRE is empty.Please set it first !!!"
        exit 1
    fi

    mkdir -p ${CFG_UPLOAD_DIR_PRE}/${IN_RELEASE_BRANCH}
    cp -rf ${CI_RELEASE_MIDDLE_DIR} ${CFG_UPLOAD_DIR_PRE}/${IN_RELEASE_BRANCH}
}

upload_release