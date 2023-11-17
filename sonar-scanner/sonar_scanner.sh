#!/bin/bash
source /opt/cxcommerce/custom-cx/external-resources/ci/scripts/envvars.sh
CI_COMMIT_BRANCH=$(echo $*|sed -s 's/ /\n/g'|grep -e '^branch='|cut -d= -f2)
CI_PULL_REQUEST_IID=$(echo $*|sed -s 's/ /\n/g'|grep -e '^pull_request_iid='|cut -d= -f2)
CI_PULL_REQUEST_SOURCE_BRANCH_NAME=$(echo $*|sed -s 's/ /\n/g'|grep -e '^pull_request_source_branch_name='|cut -d= -f2)
CI_PULL_REQUEST_TARGET_BRANCH_NAME=$(echo $*|sed -s 's/ /\n/g'|grep -e '^pull_request_target_branch_name='|cut -d= -f2)
SONAR_TOKEN=$(echo $*|sed -s 's/ /\n/g'|grep -e '^sonar_token='|cut -d= -f2)


if [[ "$CI_COMMIT_BRANCH" != "" ]]
then
    SONAR_EXTRA_PARAM="-Dsonar.branch.name=$CI_COMMIT_BRANCH"
elif [[ "$CI_PULL_REQUEST_IID" != "" ]] && [[ "$CI_PULL_REQUEST_SOURCE_BRANCH_NAME" != "" ]] && [[ "$CI_PULL_REQUEST_TARGET_BRANCH_NAME" != "" ]]
then
    SONAR_EXTRA_PARAM="-Dsonar.pullrequest.key=${CI_PULL_REQUEST_IID} -Dsonar.pullrequest.branch=${CI_PULL_REQUEST_SOURCE_BRANCH_NAME} -Dsonar.pullrequest.base=${CI_PULL_REQUEST_TARGET_BRANCH_NAME}"
else
    echo "No branch or merge request information found. Please check the CI/CD pipeline configuration."
    echo "Usage:"
    echo "# sonar_scanner.sh branch=<branch_name>"
    echo "Usage: sonar_scanner.sh pull_request_iid=<pull_request_iid> pull_request_source_branch_name=<pull_request_source_branch_name> pull_request_target_branch_name=<pull_request_target_branch_name>"
    echo "Example: sonar_scanner.sh branch=release/develop"
    echo "Example: sonar_scanner.sh pull_request_iid=1 pull_request_source_branch_name=feature/feature1 pull_request_target_branch_name=release/develop"
    exit 1
fi

cd ${CUSTOM_DIR}
/opt/sonar-scanner/bin/sonar-scanner ${SONAR_SOURCE_PARAM} -Dsonar.login=${SONAR_TOKEN} ${SONAR_EXTRA_PARAM}






cd ${{ inputs.WORKDIR }}
/opt/sonar-scanner/bin/sonar-scanner -Dsonar.host.url=${{ inputs.SONAR_URL }} -Dsonar.login=${{ inputs.SONAR_TOKEN }} -Dproject.settings=${{ inputs.SONAR_PROPERTIES_FILE }} -Dsonar.branch.name=${{ inputs.BRANCH_NAME }}