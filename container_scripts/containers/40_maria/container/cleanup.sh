#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

rm ${SCRIPTS_ROOT}/dockerfiles/maria.sh

# 
runuser --login ${USER_NAME} -c "podman volume rm ${DB_VOL_NAME}"