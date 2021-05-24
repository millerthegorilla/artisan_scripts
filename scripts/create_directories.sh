#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -z "${SCRIPTS_ROOT}" ]]
then
    echo "Error!  SCRIPTS_ROOT must be defined"
    exit 1
fi

echo -e "#******************************************************************"
echo -e "#**** you must have downloaded django_artisan to a local dir  *****"
echo -e "#******************************************************************"

read -p 'Artisan scripts project name - this is used as a directory name, so must be conformant to bash requirements : ' PROJECT_NAME
read -p 'Absolute path to code (the django_artisan folder where manage.py resides) : ' CODE_PATH
read -p "Absolute path to User home dir [$(echo ${CODE_PATH} | cut -d/ -f 1-4)] : " USER_DIR
USER_DIR=${USER_DIR:-$(echo ${CODE_PATH} | cut -d/ -f 1-4)}
read -p 'User account name ['$(echo ${CODE_PATH} | cut -d/ -f 4)'] : ' USER
USER=${USER:-$(echo ${CODE_PATH} | cut -d/ -f 4)}
mkdir -p /etc/opt/${PROJECT_NAME}/settings
# symlinks not working in podman - swag/django now mount directly to static/media/logs
mkdir -p /etc/opt/${PROJECT_NAME}/static_files

mkdir -p ${USER_DIR}/${PROJECT_NAME}/logs

sudo chcon -R -t container_file_t ${CODE_PATH}

sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}
sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}/settings
sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}/static_files
sudo chown ${USER}:${USER} ${USER_DIR}/${PROJECT_NAME}
sudo chown ${USER}:${USER} ${USER_DIR}/${PROJECT_NAME}/logs

sudo chcon -R -t container_file_t /etc/opt/${PROJECT_NAME}

if [[ ! $(sysctl net.ipv4.ip_unprivileged_port_start) == "net.ipv4.ip_unprivileged_port_start = 80" ]]
then
	sudo echo net.ipv4.ip_unprivileged_port_start=80 >> /etc/sysctl.conf
	sudo sysctl --system
fi

echo "PROJECT_NAME=${PROJECT_NAME}" > ${SCRIPTS_ROOT}/.proj
echo "CODE_PATH=${CODE_PATH}" >> ${SCRIPTS_ROOT}/.proj
echo "USER=${USER}" >> ${SCRIPTS_ROOT}/.proj
chown ${USER}:${USER} ${SCRIPTS_ROOT}/.proj
