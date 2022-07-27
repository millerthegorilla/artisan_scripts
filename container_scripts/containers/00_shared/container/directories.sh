#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

mkdir -p /etc/opt/${PROJECT_NAME}/settings
mkdir -p /etc/opt/${PROJECT_NAME}/static_files
mkdir -p /etc/opt/${PROJECT_NAME}/media_files
mkdir -p ${USER_DIR}/${PROJECT_NAME}/logs

chcon -R -t container_file_t ${CODE_PATH}

chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}
chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings
chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/static_files
chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/media_files
chown ${USER_NAME}:${USER_NAME} ${USER_DIR}/${PROJECT_NAME}
chown ${USER_NAME}:${USER_NAME} ${USER_DIR}/${PROJECT_NAME}/logs

chcon -R -t container_file_t /etc/opt/${PROJECT_NAME}