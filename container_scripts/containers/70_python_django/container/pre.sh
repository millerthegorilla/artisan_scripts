#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

if [[ ! -d ${HOST_LOG_DIR}/django ]];
then
    mkdir -p ${HOST_LOG_DIR}/django
fi
if [[ ! -d ${HOST_LOG_DIR}/gunicorn ]];
then
    mkdir ${HOST_LOG_DIR}/gunicorn
fi

chown ${USER_NAME}:${USER_NAME} ${HOST_LOG_DIR}/django ${HOST_LOG_DIR}/gunicorn

cp ${CONTAINER_SCRIPTS_ROOT}/settings/settings_env /etc/opt/${PROJECT_NAME}/settings/.env
chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings/.env
chmod 0400 /etc/opt/${PROJECT_NAME}/settings/.env

rm ${CONTAINER_SCRIPTS_ROOT}/settings/settings_env

if [[ "${DEBUG}" == "FALSE" ]]
then
    cp ${CONTAINER_SCRIPTS_ROOT}/settings/gunicorn.conf.py /etc/opt/${PROJECT_NAME}/settings/
    chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings/gunicorn.conf.py
fi
cp ${CONTAINER_SCRIPTS_ROOT}/settings/settings.py /etc/opt/${PROJECT_NAME}/settings/
chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings/settings.py