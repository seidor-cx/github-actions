#!/bin/bash
set -e

##This is a general variables file for the CI/CD pipeline
CXCOMMERCE_HOME=/opt/cxcommerce
PLATFORM_DIR=/opt/cxcommerce/hybris/bin/platform

CUSTOM_MODULES_DIR=$(echo $*|sed -s 's/ /\n/g'|grep -e '^custom_modules_dir='|cut -d= -f2)
CUSTOM_DIR=$(echo $*|sed -s 's/ /\n/g'|grep -e '^custom_dir='|cut -d= -f2)

if [ -z "${CUSTOM_MODULES_DIR}" ] ; then
    echo "Usage: ./exec_tests.sh custom_modules_dir=${{ inputs.CUSTOM_MODULES_DIR }}"
    exit 1
fi

echo "Move to platform directory ${PLATFORM_DIR}"
cd ${PLATFORM_DIR}
echo "Load ant environment variables"
source setantenv.sh
echo "Initialize tenant Junit"
ant initialize -Dtenant=junit
echo "Load extensions list"
extensions_list=$(find ${CUSTOM_DIR}/${CUSTOM_MODULES_DIR}/* -mindepth 1 -maxdepth 1 -type d ! -regex '.*cicd.*' ! -regex '.*sampledata.*' ! -regex '.*external.*' ! -regex '.*mirakl.*' ! -regex '.*test.*' -exec basename {} \;)
echo "Extensions list: ${extensions_list}"
echo "Run tests"
ant jacocoalltests -Dtestclasses.extensions="$(echo $extensions_list|sed -s 's/ /,/g')"
echo "Generate Jacoco report"
ant jacocoreport
echo "End of tests"