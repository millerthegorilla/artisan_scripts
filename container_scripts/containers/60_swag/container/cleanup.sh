#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

if [[ ${DEBUG} == "FALSE" ]];
then
   runuser --login ${USER_NAME} -c "podman volume rm ${SWAG_VOL_NAME}"

   rm dockerfiles/swag/default
fi