#!/bin/bash
set -ex

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
echo "Get list of directories on ${CXCOMMERCE_HOME}/${CUSTOM_MODULES_DIR}"
cd ${CXCOMMERCE_HOME}/${CUSTOM_MODULES_DIR}
ls -1 --color=never|sort > /tmp/list_directories
echo "Get list of extensions on localextensions.xml"
cat ${CXCOMMERCE_HOME}/hybris/config/localextensions.xml |grep name|grep -v '\-\->'|cut -d "=" -f2|sed 's/"//g'|sed 's/ \/>//g'|sed "s/'//g"|sed 's/\/>//g'|sort > /tmp/list_extensions
echo "Save the intersection between localextensions and directories on ${CXCOMMERCE_HOME}/${CUSTOM_MODULES_DIR}"
extensions_list=$(comm -12 /tmp/list_directories /tmp/list_extensions |grep -v 'cicd' |grep -v 'sampledata' |grep -v 'external' |grep -v 'mirakl' |grep -v 'test')
echo "Extensions list: ${extensions_list}"
echo "Run tests"
cd ${PLATFORM_DIR}
ant jacocoalltests -Dtestclasses.extensions="$(echo $extensions_list|sed -s 's/ /,/g')"
echo "Generate Jacoco report"
ant jacocoreport
echo "End of tests"