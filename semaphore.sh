#!/bin/bash

BASEDIR=`pwd`

# Checkout the CumulusCI repository
if [ -d ../CumulusCI ]; then
    cd ../CumulusCI
    # Uncomment and edit if you need a specific branch of CumulusCI
    git fetch --all
    git checkout feature/cloud-ci-integrations
    git pull
else
    git clone https://github.com/SalesforceFoundation/CumulusCI ../CumulusCI
    cd ../CumulusCI
    # Uncomment and edit if you need a specific branch of CumulusCI
    git fetch --all
    git checkout feature/cloud-ci-integrations
    git pull
fi

# Run the semaphore/setup.sh from CumulusCI from BASEDIR
cd $BASEDIR
export CUMULUSCI_PATH=../CumulusCI
bash $CUMULUSCI_PATH/ci/semaphore/setup.sh

# Exit based on exit status of setup
if [ $? != 0 ]; then exit 1; fi
