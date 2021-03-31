#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

read -p 'Project name:' PROJECT_NAME
read -p 'Path to code:' code_path
read -p 'Absolute path to User home dir:' user_dir

mkdir -p /etc/opt/${PROJECT_NAME}/settings
mkdir -p /etc/opt/${PROJECT_NAME}/static_files
mkdir -p ${user_dir}/${PROJECT_NAME}/logs
ln -s ${code_path} /opt/${PROJECT_NAME}
