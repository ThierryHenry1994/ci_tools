#!/bin/bash -ex

# usage: source install_git_repo.sh

workspace=${HOME}

repo_url=ssh://10.179.48.85:29418/tools/repo
repo_branch=stable

rm -fr ${workspace}/git-repo
git clone ${repo_url} -b ${repo_branch} ${workspace}/git-repo

export PATH=${workspace}/git-repo:${PATH}
