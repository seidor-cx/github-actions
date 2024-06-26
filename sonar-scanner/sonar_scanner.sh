#!/bin/bash
set -e
CI_COMMIT_BRANCH=$(echo $*|sed -s 's/ /\n/g'|grep -e '^branch_name='|cut -d= -f2)
CI_PULL_REQUEST_IID=$(echo $*|sed -s 's/ /\n/g'|grep -e '^pull_request_iid='|cut -d= -f2)
CI_PULL_REQUEST_SOURCE_BRANCH_NAME=$(echo $*|sed -s 's/ /\n/g'|grep -e '^pull_request_source_branch_name='|cut -d= -f2)
CI_PULL_REQUEST_TARGET_BRANCH_NAME=$(echo $*|sed -s 's/ /\n/g'|grep -e '^pull_request_target_branch_name='|cut -d= -f2)
SONAR_TOKEN=$(echo $*|sed -s 's/ /\n/g'|grep -e '^sonar_token='|cut -d= -f2)
SONAR_URL=$(echo $*|sed -s 's/ /\n/g'|grep -e '^sonar_url='|cut -d= -f2)
SONAR_PROPERTIES=$(echo $*|sed -s 's/ /\n/g'|grep -e '^sonar_properties='|cut -d= -f2)
SONAR_EXTRA_PARAM=$(echo $*|sed -s 's/ /\n/g'|grep -e '^sonar_extra_param='|cut -d= -f2)
WORKDIR=$(echo $*|sed -s 's/ /\n/g'|grep -e '^work_dir='|cut -d= -f2)
SONAR_BIN="/opt/sonar-scanner/bin/sonar-scanner"

function help(){
    echo "No branch or merge request information found. Please check the CI/CD pipeline configuration."
    echo "Usage:"
    echo "# sonar_scanner.sh branch_name=<branch_name>"
    echo "Usage: sonar_scanner.sh pull_request_iid=<pull_request_iid> pull_request_source_branch_name=<pull_request_source_branch_name> pull_request_target_branch_name=<pull_request_target_branch_name>"
    echo "Example: sonar_scanner.sh branch=release/develop"
    echo "Example: sonar_scanner.sh pull_request_iid=1 pull_request_source_branch_name=feature/feature1 pull_request_target_branch_name=release/develop [work_dir=dir] "
}

if [[ -z "$SONAR_URL" ]] || [[ -z "$SONAR_TOKEN" ]]
then
    help
    exit 1
fi

SONAR_SOURCE_PARAM="-Dsonar.host.url=${SONAR_URL} -Dsonar.login=${SONAR_TOKEN} -Dproject.settings=${SONAR_PROPERTIES}"

if [[ "$CI_COMMIT_BRANCH" != "" ]]
then
    SONAR_ACTION_PARAM="-Dsonar.branch.name=$CI_COMMIT_BRANCH"
elif [[ "$CI_PULL_REQUEST_IID" != "" ]] && [[ "$CI_PULL_REQUEST_SOURCE_BRANCH_NAME" != "" ]] && [[ "$CI_PULL_REQUEST_TARGET_BRANCH_NAME" != "" ]]
then
    SONAR_ACTION_PARAM="-Dsonar.pullrequest.key=${CI_PULL_REQUEST_IID} -Dsonar.pullrequest.branch=${CI_PULL_REQUEST_SOURCE_BRANCH_NAME} -Dsonar.pullrequest.base=${CI_PULL_REQUEST_TARGET_BRANCH_NAME}"
else
    help
    exit 1
fi

if [[ "$WORKDIR" != "" ]]
then
    echo "Move to ${WORKDIR}"
    cd ${WORKDIR}
fi

echo "Run sonar-scanner with params: ${SONAR_SOURCE_PARAM} ${SONAR_ACTION_PARAM} ${SONAR_EXTRA_PARAM}"
$SONAR_BIN ${SONAR_SOURCE_PARAM} ${SONAR_ACTION_PARAM} ${SONAR_EXTRA_PARAM}