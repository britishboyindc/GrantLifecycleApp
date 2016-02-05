BASEDIR=`pwd`
cd /tmp
git clone https://github.com/SalesforceFoundation/CumulusCI
cd CumulusCI
git fetch --all
git checkout features/cloud-ci-integrations
$CUMULUSCI_PATH/ci/cloud/solano/setup.sh
cd $BASEDIR
mkdir apex_debug_logs
