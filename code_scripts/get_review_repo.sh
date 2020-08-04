#!/bin/bash -ex
############ Required Params in param config file #############
# IN_WORKSPACE
# IN_LOCAL_REVIEW_BRANCH (normal is review_branch)
# IN_GERRIT_REFSPEC
# IN_GERRIT_BRANCH
# IN_GERRIT_PROJECT
###############################################################

get_review_repo()
{
    cd ${IN_WORKSPACE}

    if [[ x"${IN_LOCAL_REVIEW_BRANCH}" == x"" ]]; then
        echo "Must set IN_LOCAL_REVIEW_BRANCH in param config file"
        exit 1
    fi

    if [ -n "`git branch | grep ${IN_LOCAL_REVIEW_BRANCH} | tail -n 1 | sed "s/\* //g"`" ];then
        git checkout master
        git branch -D ${IN_LOCAL_REVIEW_BRANCH};
    fi

    local remote_name=`git remote -v | awk '{print $1}' |head -n 1`;
    git reset --hard HEAD;
    git clean -df;
    git fetch ${remote_name} ${IN_GERRIT_BRANCH};
    git checkout -b ${IN_LOCAL_REVIEW_BRANCH} ${remote_name}/${IN_GERRIT_BRANCH};
    git fetch ${remote_name} ${IN_GERRIT_REFSPEC}:${IN_GERRIT_REFSPEC} --force;
    git pull ${remote_name} ${IN_GERRIT_REFSPEC} --no-edit;
}

get_review_repo
