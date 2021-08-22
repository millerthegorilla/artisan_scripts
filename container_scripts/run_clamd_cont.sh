#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "run_clamd_cont.sh"

source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.proj

runuser --login ${USER_NAME} -P -c "podman run -dit --pod ${POD_NAME} --name ${CLAM_CONT_NAME} --restart unless-stopped ${CLAM_IMAGE}"

