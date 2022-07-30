#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${SCRIPTS_ROOT}" )" &> /dev/null && pwd )
OWNER_NAME=$(stat -c "%U" ${SCRIPT_DIR})
find ${SCRIPTS_ROOT} | xargs chown ${OWNER_NAME}:${OWNER_NAME}
find ${SCRIPTS_ROOT} -type d | grep -v "settings_files" | xargs chmod 0775
find ${SCRIPTS_ROOT} -type f | xargs chmod 0660
find ${SCRIPTS_ROOT}/.git -type d | xargs chmod 755
find ${SCRIPTS_ROOT}/.git/objects -type f | xargs chmod 664
find ${SCRIPTS_ROOT}/.git -type f | grep -v /objects/ | xargs chmod 644
chmod 0770 ${SCRIPTS_ROOT}/artisan_run.sh
chown root:root ${SCRIPTS_ROOT}/settings_files