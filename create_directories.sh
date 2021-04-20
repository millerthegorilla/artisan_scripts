#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "#******************************************************************"
echo -e "#**** you must have downloaded django_artisan to a local dir  *****"
echo -e "#******************************************************************"

read -p 'Project name - this is used as a directory name, so must be conformant to bash requirements : ' PROJECT_NAME
read -p 'Path to code (the django_artisan folder where manage.py resides) : ' CODE_PATH
read -p "Absolute path to User home dir : " USER_DIR
read -p 'User account name : ' USER

mkdir -p /etc/opt/${PROJECT_NAME}/settings
# symlinks not working in podman - swag/django now mount directly to static/media/logs
mkdir -p /etc/opt/${PROJECT_NAME}/static_files

mkdir -p ${USER_DIR}/${PROJECT_NAME}/logs

# symlinks not working in podman
#
# if [[ -L /opt/${PROJECT_NAME} ]]
# then
#     echo "**WARNING** /opt/${PROJECT_NAME} exists already!"
# else
#     ln -s ${CODE_PATH} /opt/${PROJECT_NAME}
# fi
# if [[ -L /etc/opt/${PROJECT_NAME}/static_files/static ]]
# then
#     echo "**WARNING** /etc/opt/${PROJECT_NAME}/static_files/static exists!"
# else
#     ln -s ${CODE_PATH}/static/ /etc/opt/${PROJECT_NAME}/static_files/static
# fi
# if [[ -L /etc/opt/${PROJECT_NAME}/static_files/media ]]
# then
#     echo "**WARNING** /etc/opt/${PROJECT_NAME}/static_files/media exists!"
# else
#     ln -s ${CODE_PATH}/media/ /etc/opt/${PROJECT_NAME}/static_files/media
# fi

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

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo "PROJECT_NAME=${PROJECT_NAME}" > ${SCRIPTPATH}/.proj
echo "CODE_PATH=${CODE_PATH}" >> ${SCRIPTPATH}/.proj
chown ${USER}:${USER} ${SCRIPTPATH}/.proj
