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

cd ${PLATFORM_DIR}
source setantenv.sh
cd ${CUSTOM_DIR}
ant ${ENVIRONMENT}
cd ${PLATFORM_DIR}
if [ ${INITIALIZE} -eq 0 ]; then
    ant clean all
else
    ant clean initialize | awk -f $AWK_PARSER
fi