#!/bin/bash
set -ex
source_repo=$(echo $*|sed -s 's/ /\n/g'|grep -e '^source_repo='|cut -d= -f2)
target_repo=$(echo $*|sed -s 's/ /\n/g'|grep -e '^target_repo='|cut -d= -f2)
lfs_enabled=$(echo $*|sed -s 's/ /\n/g'|grep -e '^lfs_enabled='|cut -d= -f2)
old_path=$(echo ${source_repo}|awk -F '/' '{print $NF}'|cut -d '.' -f1)
env
if [ -z "${source_repo}" ] || [ -z "${target_repo}"] ; then
    echo "Usage: ./mirroring.sh [lfs_enabled=1] source_repo=git@github.com/seidor-cx/repo.git target_repo=git@gitlab.com:group/repo.git"
    echo "lfs_enabled is optional, default is 0"
    exit 1
fi
if [ -z "${lfs_enabled}" ] ; then
    lfs_enabled=0
fi

git clone --bare ${source_repo}
cd ${old_path}
if [ ${lfs_enabled} -eq 1 ]; then
    git lfs fetch --all
fi
git push --mirror ${target_repo}
if [ ${lfs_enabled} -eq 1 ]; then
    git lfs push --all ${target_repo}
fi