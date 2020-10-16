#!/bin/bash -ex

PB_ENV_ROOT_PATH=${PWD}
PB_SCRIPT_PATH=$(cd $(dirname $0); pwd)

# set -o nounset                              # Treat unset variables as an error
# import common functions
. ${PB_SCRIPT_PATH}/common_functions.sh

PB_SCRIPT_NAME=$(basename $0)
PB_IF_DELETE=${PB_IF_DELETE:-0}
PB_CREATE_BRANCH_DIR=${PB_ENV_ROOT_PATH}/create_refs
PB_MANIFEST_GIT=manifest
PB_BUILD_GIT=build
PB_SET_REVISION_PY=${PB_SCRIPT_PATH}/set_revision.py
PB_FLAG_IS_ANDROID="false"

PB_CPU_CORE_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)


#How to use this script
function usage(){
cat <<EOF
                       -- ${PB_SCRIPT_NAME} Usage  --
Usage: ${BASH_SOURCE} [option] [args]

Options:
    -b [arg]: specify base branch
    -m [arg]: specify default manifest
    -t [arg]: specify target refs
    -u [arg]: specify manifest url
    --flag-all-xml: if add this arg,program will parse all xml to get list,
                        then create branch or tag
    --flag-is-tag: if add this arg, will create tag instead of branch
    --android: if add this arg, will replace / with _ for build_id
    -D: if add this arg, will del target branch before create it, cannot del tag
    -h      : show this usage message and exit
EOF
}


###############################################################################
#    Function: init_environment
#        Args:
#       Usage: init_environment
# Description: initialize environment
###############################################################################
function init_environment()
{

    #Save previous path
    local LC_PREV_PATH=${PWD}

    if [[ -z ${PB_TARGET_REFS} || -z ${PB_BASE_BRANCH} || -z ${PB_MANIFEST_URL} ]];then
        echo "***error: base or target branch or manifest url is not specified"
        exit 1
    fi

    #Check ${PB_CREATE_BRANCH_DIR} exist status
    if [ -d ${PB_CREATE_BRANCH_DIR} ]
    then
        rm -rf ${PB_CREATE_BRANCH_DIR}
    fi
    mkdir ${PB_CREATE_BRANCH_DIR}

    #Change dir to ${PB_CREATE_BRANCH_DIR}
    cd ${PB_CREATE_BRANCH_DIR}

    #Get manifest
    git clone ${PB_MANIFEST_URL} -b $PB_BASE_BRANCH ${PB_MANIFEST_GIT}

    #Recover previous path
    cd ${LC_PREV_PATH}

}


###############################################################################
#    Function: create_refs_for_manifest
#        Args:
#       Usage: create_refs_for_manifest
# Description: create target branch for manifest project
###############################################################################
function create_refs_for_manifest()
{

    #Change dir to ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}
    cd ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}

    git fetch -p origin

    #Check remote target branch if already exists
    get_current_set_option
    set +e
    remote_target_branch=$(git branch -r |grep -w origin/${PB_TARGET_REFS})
    set ${SET_OPTION}
    if [ ! -z "${remote_target_branch}" ]
    then
        echo "Check remote target branch ${remote_target_branch} is already exists."
        #If target branch is already exists,
        #not need execute follow command to create target branch, so return
        #exec_command "git checkout -b ${PB_TARGET_REFS} ${remote_target_branch}"
        exit 1
    fi

    #Create branch by Gerrit API
    get_current_set_option
    set +e
    PROJECT_MANIFEST_NAME=$( echo ${PB_MANIFEST_URL} | grep -o 'src.*' )
    set ${SET_OPTION}
    LC_SERVER_IP=$( echo ${PB_MANIFEST_URL} | cut -d ':' -f 2 | sed 's/\/\///g' )
    loop_exec_command_n 10 "ssh -p 29418 ${LC_SERVER_IP} gerrit create-branch ${PROJECT_MANIFEST_NAME} ${PB_TARGET_REFS} ${PB_BASE_BRANCH}"

    #Change local branch to target branch
    git fetch
    git checkout -b ${PB_TARGET_REFS} origin/${PB_TARGET_REFS}
}


###############################################################################
#    Function: get_project_list
#        Args:
#       Usage: get_project_list
# Description: get projects list
###############################################################################
function get_project_list()
{
    #Change dir to ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}
    cd ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}

    #Get all project name
    MANIFEST_LIST=${PB_MANIFEST_XML//:/\ }
    rm -rf parse_manifest.log
    for manifest_file in ${MANIFEST_LIST}
    do
        python ${PB_SCRIPT_PATH}/parse_manifest_xml.py ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}/${manifest_file} ${PB_MANIFEST_URL} >> parse_manifest.log
    done
    cp -f parse_manifest.log ${PB_ENV_ROOT_PATH}/build_manifest.log

    if [ -f "${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}/default.xml" ];then
        python ${PB_SCRIPT_PATH}/parse_manifest_xml.py ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}/default.xml ${PB_MANIFEST_URL} >> parse_manifest.log
    fi

    sort parse_manifest.log > parse_manifest_sort.log
    uniq parse_manifest_sort.log > parse_manifest.log

    mv -f parse_manifest.log ${PB_ENV_ROOT_PATH}/
}


###############################################################################
#    Function: get_all_manifests_project_list
#        Args:
#       Usage: get_all_manifests_project_list
# Description: new way to get projects list
###############################################################################
function get_all_manifests_project_list()
{
    #Change dir to ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}
    cd ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}

    python ${PB_SCRIPT_PATH}/parse_manifest_xml.py ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}/${PB_MANIFEST_XML} ${PB_MANIFEST_URL} > ${PB_ENV_ROOT_PATH}/build_manifest.log

    echo "" > parse_manifest.log

    for manifest_xml in `ls *.xml`
    do
        python ${PB_SCRIPT_PATH}/parse_manifest_xml.py ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}/${manifest_xml} ${PB_MANIFEST_URL} >> parse_manifest.log
    done

    sort parse_manifest.log > parse_manifest_sort.log
    uniq parse_manifest_sort.log > parse_manifest.log

    mv -f parse_manifest.log ${PB_ENV_ROOT_PATH}/
}


###############################################################################
#    Function: create_refs_for_projects
#        Args:
#       Usage: create_refs_for_projects
# Description: create target branch for all projects
###############################################################################
function create_refs_for_projects()
{
    #Create branch for every project in build xml by Gerrit API
    while read SERVER_NAME SERVER_PORT SRC_PROJECT_NAME SRC_RELATIVE_NAME SRC_PROJECT_PATH SRC_BRANCH_NAME
    do
        if [[ -n ${SRC_PROJECT_NAME} ]];then
            if [[ ${PB_FLAG_IS_TAG} == "true" ]];then
                loop_exec_command_n 10 "ssh -n -p ${SERVER_PORT} ${SERVER_NAME} gerrit create-branch ${SRC_PROJECT_NAME} refs/tags/${PB_TARGET_REFS} ${SRC_BRANCH_NAME}"
            else
                loop_exec_command_n 10 "ssh -n -p ${SERVER_PORT} ${SERVER_NAME} gerrit create-branch ${SRC_PROJECT_NAME} ${PB_TARGET_REFS} ${SRC_BRANCH_NAME}"
            fi
        fi
    done < ${PB_ENV_ROOT_PATH}/build_manifest.log

    #Create branch for every project not in build xml by Gerrit API
    get_current_set_option
    set +e
    grep -f ${PB_ENV_ROOT_PATH}/build_manifest.log ${PB_ENV_ROOT_PATH}/parse_manifest.log -v > ${PB_ENV_ROOT_PATH}/out_build_manifest.log

    while read SERVER_NAME SERVER_PORT SRC_PROJECT_NAME SRC_RELATIVE_NAME SRC_PROJECT_PATH SRC_BRANCH_NAME
    do
        if [[ -n ${SRC_PROJECT_NAME} ]];then
            if [[ ${PB_FLAG_IS_TAG} == "true" ]];then
                ssh -n -p ${SERVER_PORT} ${SERVER_NAME} gerrit create-branch ${SRC_PROJECT_NAME} refs/tags/${PB_TARGET_REFS} ${SRC_BRANCH_NAME}
            else
                ssh -n -p ${SERVER_PORT} ${SERVER_NAME} gerrit create-branch ${SRC_PROJECT_NAME} ${PB_TARGET_REFS} ${SRC_BRANCH_NAME}
            fi
        fi
    done < ${PB_ENV_ROOT_PATH}/out_build_manifest.log
    set $SET_OPTION

    # Change dir to ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}
    cd ${PB_CREATE_BRANCH_DIR}/${PB_MANIFEST_GIT}

    #Set manifest revision value target branch
    for manifest in `ls *.xml`
    do
        if [[ ${PB_FLAG_IS_TAG} == "true" ]];then
            ${PB_SET_REVISION_PY} -m ${manifest} -v refs/tags/${PB_TARGET_REFS}
        else
            ${PB_SET_REVISION_PY} -m ${manifest} -v refs/heads/${PB_TARGET_REFS}
        fi
    done

    change_status=$(git status -s)
    if [ "x${change_status}" != "x" ]
    then
        #Git add modify file and git commit log
        print ${change_status}
        git add *.xml


        get_current_set_option
        set -e
        git commit -m "MANIFEST:modify revision to ${PB_TARGET_REFS} at all manifests

modify revision to ${PB_TARGET_REFS} at all manifests
Test: ok
Module: MANIFEST

Ticket: -"
        set ${SET_OPTION}

        #Git push
        loop_exec_command_n 10 "git push origin ${PB_TARGET_REFS}:${PB_TARGET_REFS}"
    fi

}


#Begin to work
#Parse options
TEMP=$(getopt -o hb:t:u:m:Di: -l flag-all-xml,flag-is-tag,android -n $PB_SCRIPT_NAME -- $@)
if [ $? -ne 0 ]
then
    echo "***error: in file ${BASH_SOURCE}"
    echo "   No options matched, please check up again."
    usage
    exit 1
fi

eval set -- "${TEMP}"
while [ -n "$1" ]
do
    case "$1" in
        -b) PB_BASE_BRANCH=$2;
            shift 2;
            continue;;
        -t) PB_TARGET_REFS=$2;
            shift 2;
            continue;;
        -u) PB_MANIFEST_URL=$2;
            shift 2;
            continue;;
        -m) PB_MANIFEST_XML=$2;
            shift 2;
            continue;;
        -i) PB_FlAG_SKIP_MODIFY_BUILD_ID=$2;
            shift 2;
            continue;;
        --flag-all-xml) PB_FLAG_ALL_XML="true";
            shift;
            continue;;
        --flag-is-tag) PB_FLAG_IS_TAG="true";
            shift;
            continue;;
        --android) PB_FLAG_IS_ANDROID="true";
            shift;
            continue;;
        -D) PB_IF_DELETE=1;
            shift;
            continue;;
        -h) usage;
            exit 0;;
        --) [ -n "$2" ] && echo $1 $2 && echo -e "***error: \n   the option is error." && exit 1
            shift;
            break;;
        *)  echo "***error:"
            echo "   No found $1."
            usage;
            exit 1;;
    esac
    shift
done


echo "Start create branch..."
echo "========================================================="
echo " PB_TARGET_REFS: \"${PB_TARGET_REFS}\""
echo "   PB_BASE_BRANCH: \"${PB_BASE_BRANCH}\""
echo "  PB_MANIFEST_URL: \"${PB_MANIFEST_URL}\""
echo "========================================================="
#Init env
echo "Start initialize environment..."
init_environment
if [ $? -ne 0 ]
then
    echo "***error: ${BASH_SOURCE}"
    echo "   init_environment failed."
    exit 1
else
    echo "***debug: ${BASH_SOURCE}"
    echo "   init_environment done."
fi

#create branch at manifest git
echo "Start get project list..."
if [[ ${PB_FLAG_ALL_XML} == "true" ]];then
    get_all_manifests_project_list
else
    get_project_list
fi
if [ $? -ne 0 ]
then
    echo "***error: ${BASH_SOURCE}"
    echo "   get_project_list failed."
    exit 1
else
    echo "***debug: ${BASH_SOURCE}"
    echo "   get_project_list done."
fi


#create branch at manifest git
echo "Start create branch for manifest..."
create_refs_for_manifest
if [ $? -ne 0 ]
then
    echo "***error: ${BASH_SOURCE}"
    echo "   create_refs_for_manifest failed."
    exit 1
else
    echo "***debug: ${BASH_SOURCE}"
    echo "   create_refs_for_manifest done."
fi

#create target branch at all projects
echo "Start create branch for projects..."
create_refs_for_projects
if [ $? -ne 0 ]
then
    echo "***error: ${BASH_SOURCE}"
    echo "   create_refs_for_projects failed."
    exit 1
else
    echo "***debug: ${BASH_SOURCE}"
    echo "   create_refs_for_projects done."
fi

exit ${EXIT_OK}
