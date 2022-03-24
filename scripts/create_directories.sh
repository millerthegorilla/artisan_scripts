#!/bin/bash

source .proj

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -z "${SCRIPTS_ROOT}" ]]
then
    echo "Error!  SCRIPTS_ROOT must be defined"
    exit 1
fi

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

if [[ ! $(sysctl net.ipv4.ip_unprivileged_port_start) == "net.ipv4.ip_unprivileged_port_start = 80" ]]
then
	echo net.ipv4.ip_unprivileged_port_start=80 >> /etc/sysctl.conf
	sysctl --system
fi

echo "CODE_PATH=${CODE_PATH}" >> ${SCRIPTS_ROOT}/.archive
echo "USER_NAME=${USER_NAME}" >> ${SCRIPTS_ROOT}/.archive
chown ${USER_NAME}:${USER_NAME} ${SCRIPTS_ROOT}/.archive
