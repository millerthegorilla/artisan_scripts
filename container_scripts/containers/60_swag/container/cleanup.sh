#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

runuser --login ${USER_NAME} -c "podman volume rm ${SWAG_VOL_NAME}"