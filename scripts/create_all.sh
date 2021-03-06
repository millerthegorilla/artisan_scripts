#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -f "${SCRIPTS_ROOT}/.archive" ]]
then
    source ${SCRIPTS_ROOT}/.archive
fi

if [[ -f "${SCRIPTS_ROOT}/.proj" ]]
then
    source ${SCRIPTS_ROOT}/.proj
fi

function settings_copy()
{
    echo "Please select the settings file from the list"

    files=$(ls ${SCRIPTS_ROOT}/settings/${1})
    i=1

    for j in $files
    do
    echo "$i.$j"
    file[i]=$j
    i=$(( i + 1 ))
    done

    echo "Enter number"
    read input
    cp ${SCRIPTS_ROOT}/settings/${1}/${file[${input}]} ${SCRIPTS_ROOT}/settings/settings.py
}

if [[ "${DEBUG}" == "TRUE" ]]   ## TODO function 
then
    settings_copy "development"
else
    settings_copy "production"
fi

if [[ -n "${PROJECT_NAME}" ]]
then
    echo -e "\nProject name is ${PROJECT_NAME}"
else
    echo -e "\n*** PROJECT NAME IS NOT SET ***"
fi

set -a
source ${SCRIPTS_ROOT}/.env
set +a

if [[ ! -f ${HOST_LOG_DIR} ]]
then
    mkdir -p ${HOST_LOG_DIR}
    mkdir ${HOST_LOG_DIR}/django
    mkdir ${HOST_LOG_DIR}/gunicorn
    chown ${USER_NAME}:${USER_NAME} ${HOST_LOG_DIR}/django ${HOST_LOG_DIR}/gunicorn
fi

echo CURRENT_SETTINGS=${file[${input}]} >> .archive 
echo SWAG_CONT_NAME=${SWAG_CONT_NAME} >> ${SCRIPTS_ROOT}/.archive
echo DJANGO_CONT_NAME=${DJANGO_CONT_NAME} >> ${SCRIPTS_ROOT}/.archive

if [[ "${DEBUG}" == "TRUE" ]]
then
   runuser --login ${USER_NAME} -c "podman pod create --name ${POD_NAME} -p 0.0.0.0:8000:8000"
else
   runuser --login ${USER_NAME} -c "podman pod create --name ${POD_NAME} -p ${PORT1_DESCRIPTION} -p ${PORT2_DESCRIPTION}" # --dns-search=${POD_NAME} --dns-opt=timeout:30 --dns-opt=attempts:5
fi

if [[ "${DEBUG}" == "FALSE" ]]
then
   SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/container_scripts/run_duckdns_cont.sh
fi

## TODO change dbvol to env var set in get_variables.sh
## -o uid etc creates euid inside container ie 166355 when viewed on host.
runuser --login ${USER_NAME} -c "podman volume create ${DB_VOL_NAME}"
runuser --login ${USER_NAME} -c "podman volume create ${SWAG_VOL_NAME}"

SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/container_scripts/run_clamd_cont.sh
SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/container_scripts/run_redis_cont.sh
SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/container_scripts/run_elastic_search_cont.sh
SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/container_scripts/run_maria_cont.sh

if [[ "${DEBUG}" == "FALSE" ]]
then
    SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/container_scripts/run_swag_cont.sh
fi

SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/container_scripts/run_django_cont.sh
