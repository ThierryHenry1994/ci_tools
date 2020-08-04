#!/bin/bash -ex

############ Required Params in param config file #############
# IN_WORKSPACE
# IN_JK_PROJECT
# IN_BRANCH_NAME
# IN_LUNCH_NAME
# IN_RELEASE_BRANCH
# IN_PROJECT_CONFIG_DIR

###############################################################

############ Optional Params in param config file #############
###############################################################


source ${PB_SCRIPT_PATH}/common_tools/common_functions.sh
source ${IN_PROJECT_CONFIG_DIR}/${IN_JK_PROJECT}/release.cfg

function checkup_and_init_env()
{
    release_middle_root_dir="${IN_WORKSPACE}/../release_middle_dir"
    if [ ! -d ${release_middle_root_dir} ];then
        mkdir -p ${release_middle_root_dir}
    fi

    local lc_date=`date '+%Y%m%d'`

    if [[ -z "${release_middle_dir}" ]]; then
        release_middle_dir="${release_middle_root_dir}/${IN_BRANCH_NAME##*/}_${IN_LUNCH_NAME}_${lc_date}"
    fi

    release_middle_dir_for_developer="${release_middle_dir}/${IN_LUNCH_NAME}_for_developer"

    # clean middle directory
    if [[ -d ${release_middle_dir} ]];then
        rm -rf ${release_middle_dir}
    fi

    #create new dir for product and tool on middle
    mkdir -p "$release_middle_dir_for_developer"

    cp ${PB_CURRENT_RUN_INFO} ${release_middle_dir}

}

function copy_files_to_middle_dir()
{
    local lc_prev_path=${PWD}

    cd ${CFG_OUT_IMG_FROM_DIR}

    if [[ -n "${CFG_SYMBOLS_PATH}" ]]; then
        7z a -tzip -r symbols.zip ${CFG_SYMBOLS_PATH}
    elif [ -d "symbols" ];then
        7z a -tzip -r symbols.zip symbols
    fi

    #copy image
    if [ -f ${CFG_OUT_IMG_FROM_DIR}/developers_release.cfg ];then
        CFG_IMAGE_LIST=$(cat ${CFG_OUT_IMG_FROM_DIR}/developers_release.cfg)
    fi
    for image in ${CFG_IMAGE_LIST}
    do
        if [[ -e "${CFG_OUT_IMG_FROM_DIR}/${image}" ]];then
            cp -rL ${CFG_OUT_IMG_FROM_DIR}/${image} ${release_middle_dir_for_developer}

            if [[ -f "${CFG_OUT_IMG_FROM_DIR}/${image}" ]];then
                md5sum ${image} >> image_md5sum.txt
            fi
        else
            continue
        fi
    done

    for image in ${CFG_CUSTOM_IMAGE_LIST}
    do
        if [[ -e "${image}" ]];then
            cp -rL ${image} ${release_middle_dir_for_developer}

            if [[ -f "${image}" ]];then
                md5sum ${image} >> image_md5sum.txt
            fi
        else
            continue
        fi
    done

    cp -r ${CFG_OUT_IMG_FROM_DIR}/image_md5sum.txt ${release_middle_dir_for_developer}


    #cp installed info file
    for file in ${CFG_OTHER_FILE_LIST}
    do
        if [[ -e "${CFG_OUT_IMG_FROM_DIR}/${file}" ]];then
            cp -rL ${CFG_OUT_IMG_FROM_DIR}/${file} ${release_middle_dir}
        else
            continue
        fi
    done

    # copy update key
    if [[ ${CFG_NEED_UPDATE_KEY} == "true" ]];then
        touch ${release_middle_dir_for_developer}/UPDATE.KEY
    fi

    if [[ "${CFG_INCLUDE_ADDON}" == "true" && -n "${CFG_ADDON_FROM_DIR}" ]];then
        mkdir -p ${release_middle_dir}/addon_x86_64
        cp ${CFG_ADDON_FROM_DIR}/*.zip ${release_middle_dir}/addon_x86_64
    fi

    if [[ -n "${CFG_MAPING_DIR}" ]]; then
        mkdir -p ${release_middle_dir}/mapping_info
        cd ${CFG_MAPING_DIR}
        find . -name maping -type d | xargs -I {} cp {} --parent -r ${release_middle_dir}/mapping_info

    fi

    cd ${lc_prev_path}
}

checkup_and_init_env
copy_files_to_middle_dir

echo CI_RELEASE_MIDDLE_DIR=${release_middle_dir} >> ${PB_CI_PARAMS_CFG_TMP}