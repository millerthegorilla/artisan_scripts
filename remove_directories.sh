#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -e .archive ]]
then
	source .archive
fi

if [[ ! -n ${PROJECT_NAME} ]]
then
	read -p "Enter artisan scripts project name ie /etc/opt/PROJECT_NAME/settings etc : " PROJECT_NAME
fi

if [[ -e /etc/opt/${PROJECT_NAME}/ ]]
then
	rm -rf /etc/opt/${PROJECT_NAME}
fi

read -p "Enter path to home folder where ${PROJECT_NAME} logs are stored : " home_dir

if [[ -e ${home_dir}/${PROJECT_NAME} ]]
then
	rm -rf ${home_dir}/${PROJECT_NAME}
else
	echo -e "Couldn't find a directory at ${home_dir}/${PROJECT_NAME}!!!"
fi