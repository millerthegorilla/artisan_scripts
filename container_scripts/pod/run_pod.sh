#!/bin/bash

source ${SCRIPTS_ROOT}/.proj

if [[ "${DEBUG}" == "TRUE" ]]
then
   runuser --login ${USER_NAME} -c "podman pod create --name ${POD_NAME} -p 0.0.0.0:8000:8000"
else
   runuser --login ${USER_NAME} -c "podman pod create --name ${POD_NAME} -p ${PORT1_DESCRIPTION} -p ${PORT2_DESCRIPTION}" # --dns-search=${POD_NAME} --dns-opt=timeout:30 --dns-opt=attempts:5
fi