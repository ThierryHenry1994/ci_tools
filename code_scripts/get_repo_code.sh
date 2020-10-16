#!/bin/bash -ex

############ Required Params in param config file #############
# IN_WORKSPACE
# IN_MANIFEST_URL
# IN_BRANCH_NAME
# IN_MANIFEST_XML
###############################################################

############ Optional Params in param config file #############
# IN_REPO_INIT_PARAMS
# IN_REPO_SYNC_PARAMS
# IN_DIFF_REPO_LIST (is need get diff repo list)
###############################################################

init_repo_env()
{
    local pre_dir=$(pwd)

    mkdir -p ${IN_WORKSPACE}
    cd ${IN_WORKSPACE}
    if [[ x"${IN_DIFF_REPO_LIST}" != x"" ]] && [[ -f ${IN_WORKSPACE}/.repo/manifests/${IN_MANIFEST_XML} ]]; then
        ${PB_SCRIPT_PATH}/common_tools/parse_manifest_xml.py ${IN_WORKSPACE}/.repo/manifests/${IN_MANIFEST_XML} ${IN_MANIFEST_URL} > ${IN_WORKSPACE}/repo_list_before.log
    fi
    repo init -u ${IN_MANIFEST_URL} -b ${IN_BRANCH_NAME} -m ${IN_MANIFEST_XML} ${IN_REPO_INIT_PARAMS}
    repo sync ${IN_REPO_SYNC_PARAMS}

    if [[ x"${IN_DIFF_REPO_LIST}" != x"" ]]; then
        ${PB_SCRIPT_PATH}/common_tools/parse_manifest_xml.py ${IN_WORKSPACE}/.repo/manifests/${IN_MANIFEST_XML} ${IN_MANIFEST_URL} > ${IN_WORKSPACE}/repo_list_current.log
        set +e
        diff_result=$(echo `diff ${IN_WORKSPACE}/repo_list_before.log ${IN_WORKSPACE}/repo_list_current.log | grep \<`)
        set -e
        if [ x"$diff_result" != x"" ];
        then
            ## if remove project from manifest,need clean build result
            rm -rf ${IN_WORKSPACE}/out
        fi
    fi

    cd ${pre_dir}
}

init_repo_env