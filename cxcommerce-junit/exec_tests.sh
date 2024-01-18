#!/bin/bash
set -ex

##This is a general variables file for the CI/CD pipeline
CXCOMMERCE_HOME=/opt/cxcommerce
PLATFORM_DIR=/opt/cxcommerce/hybris/bin/platform
LIST_EXTENSIONS_DIR=/tmp/list_directories
LIST_EXTENSIONS_ACTIVE=/tmp/list_extensions

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
echo "Get list of directories on ${CUSTOM_DIR}/${CUSTOM_MODULES_DIR}"
cd ${CUSTOM_DIR}/${CUSTOM_MODULES_DIR}
ls -1 --color=never|sort
ls -1 --color=never|sort > ${LIST_EXTENSIONS_DIR}
echo "Get list of extensions on localextensions.xml"
cat ${CXCOMMERCE_HOME}/hybris/config/localextensions.xml |grep name|grep -v '\-\->'|cut -d "=" -f2|sed 's/"//g'|sed 's/ \/>//g'|sed "s/'//g"|sed 's/\/>//g'
cat ${CXCOMMERCE_HOME}/hybris/config/localextensions.xml |grep name|grep -v '\-\->'|cut -d "=" -f2|sed 's/"//g'|sed 's/ \/>//g'|sed "s/'//g"|sed 's/\/>//g'|sort > ${LIST_EXTENSIONS_ACTIVE}
echo "Save the intersection between localextensions and directories on ${CUSTOM_DIR}/${CUSTOM_MODULES_DIR}"
echo "DEBUG: show content from ${LIST_EXTENSIONS_ACTIVE}"
cat ${LIST_EXTENSIONS_ACTIVE}
echo "DEBUG: show content from ${LIST_EXTENSIONS_DIR}"
cat ${LIST_EXTENSIONS_DIR}
extensions_list=$(comm -12 ${LIST_EXTENSIONS_DIR} ${LIST_EXTENSIONS_ACTIVE} |grep -v 'cicd' |grep -v 'sampledata' |grep -v 'external' |grep -v 'mirakl' |grep -v 'test')
echo "Extensions list: ${extensions_list}"
echo "Run tests"
cd ${PLATFORM_DIR}
ant jacocoalltests -Dtestclasses.extensions="$(echo $extensions_list|sed -s 's/ /,/g')"
echo "Generate Jacoco report"
ant jacocoreport
echo "End of tests"