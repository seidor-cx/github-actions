#!/bin/bash
set -e
# Usage:
# ./merge.sh src=<SOURCE_BRANCH> dest=<dest_branch>
SOURCE_BRANCH=$(echo $*|sed -s 's/ /\n/g'|grep -e '^source_branch_name='|cut -d= -f2)
TARGET_BRANCH=$(echo $*|sed -s 's/ /\n/g'|grep -e '^target_branch_name='|cut -d= -f2)
WORKDIR=$(echo $*|sed -s 's/ /\n/g'|grep -e '^workdir='|cut -d= -f2)

if [ -z "${SOURCE_BRANCH}" ] || [ -z "${TARGET_BRANCH}" ]; then
    echo "Usage: ./merge.sh source_branch_name=<SOURCE_BRANCH> target_branch_name=<dest_branch> workdir=<WORKDIR>"
    exit 1
fi

echo "Move to ${WORKDIR}"
cd ${WORKDIR}
echo "Upgrade change index"
git fetch --all
echo "Change to ${TARGET_BRANCH}"
git checkout ${TARGET_BRANCH}
echo "Pull changes from ${TARGET_BRANCH}"
git pull
echo "Change to ${SOURCE_BRANCH}"
git checkout ${SOURCE_BRANCH}
echo "Pull changes from ${SOURCE_BRANCH}"
git pull
echo "Merge ${SOURCE_BRANCH} into ${TARGET_BRANCH}"
git merge ${TARGET_BRANCH}