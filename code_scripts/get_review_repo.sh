#!/bin/bash -ex
############ Required Params in param config file #############
# IN_WORKSPACE
# IN_MANIFEST_URL
# IN_MANIFEST_XML
# IN_LOCAL_REVIEW_BRANCH (normal is review_branch)
# IN_GERRIT_REFSPEC
# IN_GERRIT_BRANCH
# IN_GERRIT_PROJECT
###############################################################

get_review_repo()
{
	cd ${IN_WORKSPACE}
	${PB_SCRIPT_PATH}/common_tools/parse_manifest_xml.py ${IN_WORKSPACE}/.repo/manifests/${IN_MANIFEST_XML} ${IN_MANIFEST_URL} > ${IN_WORKSPACE}/repo_list_info.log
	while read server_name server_port src_project_name src_relative_name src_project_path src_remote_name src_branch_name
    do
        if [ ${src_project_name} = ${IN_GERRIT_PROJECT} ];then
            gerrit_project_path="${IN_WORKSPACE}/${src_project_path}";

            echo "gerrit_project_path ${gerrit_project_path}";

            break;
        fi
    done < ${IN_WORKSPACE}/repo_list_info.log

    cd ${gerrit_project_path};

    if [[ x"${IN_LOCAL_REVIEW_BRANCH}" == x"" ]]; then
    	echo "Must set IN_LOCAL_REVIEW_BRANCH in param config file"
    	exit 1
    fi

    if [ -n "`git branch | grep ${IN_LOCAL_REVIEW_BRANCH} | tail -n 1 | sed "s/\* //g"`" ];then
        git branch -D ${IN_LOCAL_REVIEW_BRANCH};
    fi

    local remote_name=`git remote -v | awk '{print $1}' |head -n 1`;
    git reset --hard HEAD;
    git clean -df;
    fetch_params=""
    if [[ -f .git/shallow ]]; then
        ## sometime need double sync if repository is shallow
        git fetch ${remote_name} ${IN_GERRIT_BRANCH} --unshallow;
    fi
    git fetch ${remote_name} ${IN_GERRIT_BRANCH};
    git checkout -b ${IN_LOCAL_REVIEW_BRANCH} ${remote_name}/${IN_GERRIT_BRANCH};
    git fetch ${remote_name} ${IN_GERRIT_REFSPEC}:${IN_GERRIT_REFSPEC} --force;
    git pull ${remote_name} ${IN_GERRIT_REFSPEC} --no-edit;

    cd ${IN_WORKSPACE}
}

get_review_repo
