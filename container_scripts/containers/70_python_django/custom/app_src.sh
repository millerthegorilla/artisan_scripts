#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

if [[ -z ${USER_NAME} ]]
then
    read -p "Enter username : " USER_NAME
fi
read -p "File with github addresses : " -e GITFILE
read -p "Directory to clone into : " -e GITDIR
LINES=$(cat ${GITFILE})
for line in $LINES
do
  runuser --login ${USER_NAME} -P -c "git -C ${GITDIR} clone ${line}"
done