#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

read -p 'Project name : ' PROJECT_NAME
read -p 'Path to code (the django_artisan folder where manage.py resides) : ' code_path
read -p 'Absolute path to User home dir : ' user_dir
read -p 'User account name : ' user 

mkdir -p /etc/opt/${PROJECT_NAME}/settings
mkdir -p /etc/opt/${PROJECT_NAME}/static_files
mkdir -p ${user_dir}/${PROJECT_NAME}/logs
ln -s ${code_path} /opt/${PROJECT_NAME}
ln -s ${code_path}/static/ /etc/opt/${PROJECT_NAME}/static_files/static
ln -s ${code_path}/media/ /etc/opt/${PROJECT_NAME}/static_files/media

sudo chcon -R -t container_file_t /opt/${PROJECT_NAME}/

sudo chown $user:$user /etc/opt/${PROJECT_NAME}
sudo chown $user:$user /etc/opt/${PROJECT_NAME}/settings
sudo chown $user:$user /etc/opt/${PROJECT_NAME}/static_files
sudo chown $user:$user ${user_dir}/${PROJECT_NAME}/logs

if [[ ! $(sysctl net.ipv4.ip_unprivileged_port_start) == "net.ipv4.ip_unprivileged_port_start = 80" ]]
then
	sudo echo net.ipv4.ip_unprivileged_port_start=80 >> /etc/sysctl.conf
	sudo sysctl --system
fi
