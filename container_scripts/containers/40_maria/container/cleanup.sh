#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

if [[ -e ${CURRENT_DIR}/../image/dockerfile/maria.sh ]];
then
   rm -rf ${CURRENT_DIR}/../image/dockerfile/maria.sh
fi

if [[ -n "${DB_VOL}" ]];
then
   runuser --login ${USER_NAME} -c "podman volume rm ${DB_VOL}"
fi