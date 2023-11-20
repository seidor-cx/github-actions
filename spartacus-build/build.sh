#!/bin/bash

set -e
WORKDIR=$(echo $*|sed -s 's/ /\n/g'|grep -e '^workdir='|cut -d= -f2)

if [ -z "${WORKDIR}" ] ; then
    echo "Usage: ./build.sh workdir=${{ inputs.WORKDIR }}"
    exit 1
fi

cd ${WORKDIR}
yarn install
yarn build