#!/bin/bash -ex

############ Required Params in param config file #############
# IN_WORKSPACE
###############################################################

############ Optional Params in param config file #############
###############################################################

clean_env()
{
    mkdir -p ${IN_WORKSPACE}
    rm -fr ${IN_WORKSPACE}/*
}

clean_env