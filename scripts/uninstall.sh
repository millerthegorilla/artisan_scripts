#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${SCRIPTS_ROOT}" )" &> /dev/null && pwd )
OWNER_NAME=$(stat -c "%U" ${SCRIPT_DIR})
find . | xargs chown ${OWNER_NAME}:${OWNER_NAME}
find . -type d | xargs chmod 0775
find . -type f | xargs chmod 0660
find .git -type d | xargs chmod 755
find .git/objects -type f | xargs chmod 664
find .git -type f | grep -v /objects/ | xargs chmod 644
chmod 0770 ./artisan_run.sh