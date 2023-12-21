#!/bin/bash
set -e

ACTOR_NAME=$(echo $*|sed -s 's/ /\n/g'|grep -e '^actor_name='|cut -d= -f2)
ACTOR_MAIL=$(echo $*|sed -s 's/ /\n/g'|grep -e '^actor_mail='|cut -d= -f2)
SECRET=$(echo $*|sed -s 's/ /\n/g'|grep -e '^secret='|cut -d= -f2)
CONFIG=$(echo $*|sed -s 's/ /\n/g'|grep -e '^config='|cut -d= -f2)

if [ -z "${ACTOR_NAME}" ] || [ -z "${ACTOR_MAIL}" ] || [ -z "${SECRET}" ] || [ -z "${CONFIG}" ] ; then
    echo "Usage: ./add-ssh-write-credentials.sh actor_name=John actor_mail=john@mail.com secret=ssh-private-key config=ssh-config"
    exit 1
fi

mkdir -p $HOME/.ssh
echo "${CONFIG}" >> $HOME/.ssh/config
secret_file="$(echo ${SECRET}|grep IdentityFile|awk '{print $NF}')"
echo "${SECRET}" > ${secret_file}
chmod 600 ${secret_file}
git config --global user.email "${ACTOR_MAIL}"
git config --global user.name "${ACTOR_NAME}"