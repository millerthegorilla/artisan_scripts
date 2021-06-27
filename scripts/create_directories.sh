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
mkdir -p /etc/opt/${PROJECT_NAME}/database

mkdir -p ${USER_DIR}/${PROJECT_NAME}/logs

sudo chcon -R -t container_file_t ${CODE_PATH}

sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}
sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}/settings
sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}/static_files
sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}/database
sudo chown ${USER}:${USER} ${USER_DIR}/${PROJECT_NAME}
sudo chown ${USER}:${USER} ${USER_DIR}/${PROJECT_NAME}/logs

sudo chcon -R -t container_file_t /etc/opt/${PROJECT_NAME}

if [[ ! $(sysctl net.ipv4.ip_unprivileged_port_start) == "net.ipv4.ip_unprivileged_port_start = 80" ]]
then
	sudo echo net.ipv4.ip_unprivileged_port_start=80 >> /etc/sysctl.conf
	sudo sysctl --system
fi

echo "PROJECT_NAME=${PROJECT_NAME}" >> ${SCRIPTS_ROOT}/.archive
echo "CODE_PATH=${CODE_PATH}" >> ${SCRIPTS_ROOT}/.archive
echo "USER=${USER}" >> ${SCRIPTS_ROOT}/.archive
chown ${USER}:${USER} ${SCRIPTS_ROOT}/.archive
