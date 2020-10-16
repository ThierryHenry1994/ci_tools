#!/bin/bash -ex

############ Required Params in param config file #############
# IN_JK_PROJECT
# IN_RELEASE_BRANCH
# IN_PROJECT_CONFIG_DIR
# IN_BRANCH_NAME
# IN_MAKER_VERSION

###############################################################

############ Optional Params in param config file #############
###############################################################

# CI_RELEASE_MIDDLE_DIR 为其他脚本的输出变量

source ${PB_SCRIPT_PATH}/common_tools/common_functions.sh
source ${IN_PROJECT_CONFIG_DIR}/${IN_JK_PROJECT}/release.cfg

function make_prg()
{
    local prev_path=${PWD}

    build_num=$(echo ${IN_BRANCH_NAME##*/} | cut -d "_" -f 2)
    release_version=$(echo ${IN_BRANCH_NAME##*/} | cut -d "_" -f 1)

    if [ -z ${CFG_OUT_IMG_FROM_DIR} ];then
        error "CFG_OUT_IMG_FROM_DIR(${CFG_OUT_IMG_FROM_DIR}) is invalid"
        exit 1
    fi

    if [ -z ${CFG_PRG_NAME_BASE} ];then
        error "CFG_PRG_NAME_BASE(${${CFG_PRG_NAME_BASE}}) is invalid"
        exit 1
    fi

    if [ -z ${build_num} -o -z ${IN_MAKER_VERSION} ];then
        error "MAKER_VERSION or BUILD_NUM  is null"
        exit 1
    fi

    git clone ${CFG_MAKE_PRG_SCRIPT_URL} -b ${CFG_MAKE_PRG_SCRIPT_BRANCH} ${CFG_OUT_IMG_FROM_DIR}/prg_scripts

    local LC_VERSION_PRE=$(echo ${release_version} | cut -d '.' -f 1)
    local LC_VERSION_SUFF=$(echo ${release_version} | cut -d '.' -f 2)
    local LC_VERSION_PRE_FMT=$(printf %02d ${LC_VERSION_PRE})
    local LC_VERSION_ESC=${LC_VERSION_PRE_FMT}${LC_VERSION_SUFF}

    local LC_BITS=$(echo -n "${LC_VERSION_ESC}" | wc -c)
    if [[ ${LC_BITS} -ne 8 ]]
    then
        error "LC_VERSION_ESC(${LC_VERSION_ESC}) is invalid"
        exit 1
    fi

    cd ${CFG_OUT_IMG_FROM_DIR}/prg_scripts
    ./make_prg.sh -id ${CFG_OUT_IMG_FROM_DIR} -od ${CFG_OUT_IMG_FROM_DIR}/${CFG_PRG_NAME_BASE} -pv ${LC_VERSION_ESC} -bn ${build_num} -mv ${IN_MAKER_VERSION}


    cp -r ${CFG_OUT_IMG_FROM_DIR}/${CFG_PRG_NAME_BASE} ${CI_RELEASE_MIDDLE_DIR}
    cd ${CI_RELEASE_MIDDLE_DIR}/${CFG_PRG_NAME_BASE}
    md5sum $(find . -name *.PRG) > prg_md5sum.txt

    cd ${lc_prev_path}
}

make_prg