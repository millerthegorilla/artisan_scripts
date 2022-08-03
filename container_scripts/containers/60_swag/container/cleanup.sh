#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

if [[ ${DEBUG} == "FALSE" ]];
then
   if [[ -n ${SWAG_VOL_NAME} ]];
   then
      if runuser --login ${USER_NAME} -c "podman volume exists ${SWAG_VOL_NAME}";
      then
         runuser --login ${USER_NAME} -c "podman volume rm ${SWAG_VOL_NAME}"
      fi
   fi
   rm ${CURRENT_DIR}/../image/dockerfile/swag/default
fi