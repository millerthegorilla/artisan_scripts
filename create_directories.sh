#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "#******************************************************************"
echo -e "#**** you must have downloaded django_artisan to a local dir  *****"
echo -e "#******************************************************************"

read -p 'Project name : ' PROJECT_NAME
read -p 'Path to code (the django_artisan folder where manage.py resides) : ' CODE_PATH
read -p 'Absolute path to User home dir : ' USER_DIR
read -p 'User account name : ' USER

mkdir -p /etc/opt/${PROJECT_NAME}/settings
mkdir -p /etc/opt/${PROJECT_NAME}/static_files
mkdir -p ${USER_DIR}/${PROJECT_NAME}/logs

ln -s ${CODE_PATH} /opt/${PROJECT_NAME}
ln -s ${CODE_PATH}/static/ /etc/opt/${PROJECT_NAME}/static_files/static
ln -s ${CODE_PATH}/media/ /etc/opt/${PROJECT_NAME}/static_files/media

sudo chcon -R -t container_file_t /opt/${PROJECT_NAME}/

sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}
sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}/settings
sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}/static_files
sudo chown ${USER}:${USER} /etc/opt/${PROJECT_NAME}
sudo chown ${USER}:${USER} ${USER_DIR}/${PROJECT_NAME}/logs

if [[ ! $(sysctl net.ipv4.ip_unprivileged_port_start) == "net.ipv4.ip_unprivileged_port_start = 80" ]]
then
	sudo echo net.ipv4.ip_unprivileged_port_start=80 >> /etc/sysctl.conf
	sudo sysctl --system
fi

echo $PROJECT_NAME > .proj
chown ${USER}:${USER} .proj
