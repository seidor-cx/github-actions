#!/bin/bash
# Usage:
# ./merge.sh src=<SOURCE_BRANCH> dest=<dest_branch>
SOURCE_BRANCH=$(echo $*|sed -s 's/ /\n/g'|grep -e '^source_branch_name='|cut -d= -f2)
TARGET_BRANCH=$(echo $*|sed -s 's/ /\n/g'|grep -e '^target_branch_name='|cut -d= -f2)

if [ -z "${SOURCE_BRANCH}" ] || [ -z "${TARGET_BRANCH}" ]; then
    echo "Usage: ./merge.sh source_branch_name=<SOURCE_BRANCH> target_branch_name=<dest_branch>"
    exit 1
fi

git fetch --all
git checkout ${TARGET_BRANCH}
git pull
git checkout ${SOURCE_BRANCH}
git pull
git merge ${TARGET_BRANCH}