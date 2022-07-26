#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

runuser --login ${USER_NAME} -P -c "podman run -dit --pod ${POD_NAME} ${AUTO_UPDATES} --name ${REDIS_CONT_NAME} ${REDIS_IMAGE}"
