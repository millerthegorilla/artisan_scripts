#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

if [[ "${DEBUG}" == "TRUE" ]]
then
    exit 0
fi

source ${PROJECT_SETTINGS}

runuser --login ${USER_NAME} -c "podman volume create ${SWAG_VOL_NAME}"

if [[ -n "${SWAG_HOST_LOG_DIR}" && ! -f ${SWAG_HOST_LOG_DIR} ]]
then
    mkdir -p ${SWAG_HOST_LOG_DIR}
    chown ${USER_NAME}:${USER_NAME} ${SWAG_HOST_LOG_DIR}
fi

echo -e "\n\nIs the project 'pre-production'?  If it is then the swag container can be created with a 'staging' flag, that will see certificate requests sent to the lets encrypt staging api.  Doing this will prevent any rate-limits set by lets encrypt.  Note though, that to place the site into production, you will need to recreate the swag container with this staging flag set to false.\nhttps://letsencrypt.org/docs/staging-environment/\n"
echo -e "Set staging to True?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) staging=True; break;;
        No ) staging=False; break;;
    esac
done