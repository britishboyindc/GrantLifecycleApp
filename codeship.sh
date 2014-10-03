#!/bin/bash -x

BASEDIR=`pwd`

# Checkout the CumulusCI repository
if [ -d ../CumulusCI ]; then
    cd ../CumulusCI
    git pull
    git checkout feature/13-codeship-integration
else
    git clone https://github.com/SalesforceFoundation/CumulusCI ../CumulusCI
    cd ../CumulusCI
    git checkout feature/13-codeship-integration
fi

# Run the codeship.sh from CumulusCI from BASEDIR
cd $BASEDIR
export CUMULUSCI_PATH=../CumulusCI
bash $CUMULUSCI_PATH/ci/codeship.sh

# Exit based on exit status of CumulusCI's codeship.sh
if [ $? != 0 ]; then exit 1; fi
