#!/bin/bash
set -e
##This is a general variables file for the CI/CD pipeline
PLATFORM_DIR=/opt/cxcommerce/hybris/bin/platform
INITIALIZE=$(echo $*|sed -s 's/ /\n/g'|grep -e '^initialize='|cut -d= -f2)
CUSTOM_DIR=$(echo $*|sed -s 's/ /\n/g'|grep -e '^custom_dir='|cut -d= -f2)
ENVIRONMENT=$(echo $*|sed -s 's/ /\n/g'|grep -e '^environment='|cut -d= -f2)
AWK_PARSER="$GITHUB_ACTION_PATH/parse_initialize_errors.awk"

if [ -z "${INITIALIZE}" ] ; then
    echo "Usage: ./build_cxcommerce.sh initialize=<0|1> custom_dir=${{ inputs.CUSTOM_DIR }} environment=${{ inputs.ENVIRONMENT }}"
    exit 1
fi

echo "Move to platform directory ${PLATFORM_DIR}"
cd ${PLATFORM_DIR}
echo "Load ant environment variables"
source setantenv.sh
echo "Move to custom directory ${CUSTOM_DIR}"
cd ${CUSTOM_DIR}
echo "Set environment configuration"
ant ${ENVIRONMENT}
echo "Move to platform directory ${PLATFORM_DIR}"
cd ${PLATFORM_DIR}
if [ ${INITIALIZE} -eq 0 ]; then
    echo "Build Commerce"
    ant clean all
else
    echo "Build & Initialize Commerce"
    #ant clean initialize | awk -f $AWK_PARSER
    ant clean initialize

fi