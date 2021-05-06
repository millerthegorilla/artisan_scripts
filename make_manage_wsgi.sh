#!/bin/bash

###  This script will rebuild manage.py and wsgi.py in case a git pull of the main django_artisan code base
###  removes them.


if [[ -e .archive ]]
then
	source .archive
fi

read -p "Enter artisan scripts project name, as in /etc/opt/*PROJECT_NAME*/settings etc [${PROJECT_NAME}] : " project_name
PROJECT_NAME=${project_name:-${PROJECT_NAME}}

read -p "Enter path to django_artisan code where manage.py resides [${CODE_PATH}] : " code_path 
CODE_PATH=${code_path:-${CODE_PATH}}

read -p "Enter name of django project, the folder in which wsgi.py resides [${DJANGO_PROJECT_NAME}] : " django_project_name
DJANGO_PROJECT_NAME=${django_project_name:-${DJANGO_PROJECT_NAME}}

cat ./templates/manage.py | envsubst > ${CODE_PATH}/manage.py
cat ./templates/wsgi.py | envsubst > ${CODE_PATH}/${django_project_name}/wsgi.py