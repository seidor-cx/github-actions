#!/bin/bash

set -e

CFG_FILE=$(echo $*|sed -s 's/ /\n/g'|grep -e '^config_file='|cut -d= -f2)

if [[ -z $CFG_FILE ]]; then
    echo "You should pass config file as param"
    exit 1
fi

source $HOME/.nvm/nvm.sh
for CARTRIDGE in $(yq e '.unit_test_cartridges | keys | .[]' "$CFG_FILE"); do
    echo "Executing Unit tests for cartridge: $CARTRIDGE"
    CARTRIDGE_DIR=$(yq e '.unit_test_cartridges."'"$CARTRIDGE"'".path' "$CFG_FILE")
    cd $(CARTRIDGE_DIR)
    npm run cover
done
echo "Information: Unit tests execution success"
