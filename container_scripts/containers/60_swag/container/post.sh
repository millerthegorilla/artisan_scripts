#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

if [[ "${DEBUG}" == "TRUE" ]]
then
    exit 0
fi

runuser --login ${USER_NAME} -P -c "podman exec -it ${SWAG_CONT_NAME} bash -c \"chown abc -R ${SWAG_CONT_VOL_STATIC}\""