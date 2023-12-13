#!/bin/bash
set -e

##This is a general variables file for the CI/CD pipeline
CXCOMMERCE_HOME=/opt/cxcommerce
PLATFORM_DIR=/opt/cxcommerce/hybris/bin/platform
PROJECT_DIR=/opt/cxcommerce/custom-cx

CUSTOM_MODULES_DIR=$(echo $*|sed -s 's/ /\n/g'|grep -e '^custom_modules_dir='|cut -d= -f2)

if [ -z "${CUSTOM_MODULES_DIR}" ] ; then
    echo "Usage: ./exec_tests.sh custom_modules_dir=${{ inputs.CUSTOM_MODULES_DIR }}"
    exit 1
fi

cd ${PLATFORM_DIR}
source setantenv.sh
ant initialize -Dtenant=junit
extensions_list=$(find ${PROJECT_DIR}/${CUSTOM_MODULES_DIR}/* -mindepth 1 -maxdepth 1 -type d ! -regex '.*cicd.*' ! -regex '.*sampledata.*' ! -regex '.*external.*' -exec basename {} \;)
ant jacocoalltests -Dtestclasses.extensions="$(echo $extensions_list|sed -s 's/ /,/g')"
cd ${PLATFORM_DIR}
ant jacocoreport
cd ${PROJECT_DIR}