#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

runuser --login ${USER_NAME} -c "podman volume create ${DB_VOL}"

if [[ ${DEBUG} == "TRUE" ]]
then
    cp ${CURRENT_DIR}/../variables/templates/maria_dev.sh ${CURRENT_DIR}/../image/dockerfile/maria.sh
 else
    cp ${CURRENT_DIR}/../variables/templates/maria_prod.sh ${CURRENT_DIR}/../image/dockerfile/maria.sh
fi