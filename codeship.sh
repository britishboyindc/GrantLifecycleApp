#!/bin/bash

BASEDIR=`pwd`

# Checkout the CumulusCI repository
if [ -d ../CumulusCI ]; then
    cd ../CumulusCI
    git fetch --all
    git checkout feature/13-codeship-integration
    git pull
else
    git clone https://github.com/SalesforceFoundation/CumulusCI ../CumulusCI
    cd ../CumulusCI
    git fetch --all
    git checkout feature/13-codeship-integration
fi

# Run the codeship.sh from CumulusCI from BASEDIR
cd $BASEDIR
export CUMULUSCI_PATH=../CumulusCI
bash $CUMULUSCI_PATH/ci/codeship.sh

# Exit based on exit status of CumulusCI's codeship.sh
if [ $? != 0 ]; then exit 1; fi
