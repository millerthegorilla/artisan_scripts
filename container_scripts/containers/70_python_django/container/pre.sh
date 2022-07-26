#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

if [[ ! -f ${HOST_LOG_DIR} ]]
then
    mkdir -p ${HOST_LOG_DIR}
    mkdir ${HOST_LOG_DIR}/django
    mkdir ${HOST_LOG_DIR}/gunicorn
    chown ${USER_NAME}:${USER_NAME} ${HOST_LOG_DIR}/django ${HOST_LOG_DIR}/gunicorn
fi

cp ${SCRIPTS_ROOT}/settings/settings_env /etc/opt/${PROJECT_NAME}/settings/.env
chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings/.env
chmod 0400 /etc/opt/${PROJECT_NAME}/settings/.env

rm ${SCRIPTS_ROOT}/settings/settings_env

if [[ "${DEBUG}" == "FALSE" ]]
then
    cp ${SCRIPTS_ROOT}/settings/gunicorn.conf.py /etc/opt/${PROJECT_NAME}/settings/
    chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings/gunicorn.conf.py
fi
cp ${SCRIPTS_ROOT}/settings/settings.py /etc/opt/${PROJECT_NAME}/settings/
chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings/settings.py