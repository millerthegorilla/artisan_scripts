#!/bin/bash

###  This script will rebuild manage.py and wsgi.py in case a git pull of the main django_artisan code base
###  removes them.


if [[ -e .archive ]]
then
	source .archive
fi

if [[ -z "${PROJECT_NAME}" ]]
then
	read -p "Enter artisan scripts project name, as in /etc/opt/*PROJECT_NAME*/settings etc [${PROJECT_NAME}] : " project_name
    PROJECT_NAME=${project_name:-${PROJECT_NAME}}
fi

if [[ -z "${CODE_PATH}" ]]
then
    read -p "Enter path to django_artisan code where manage.py resides [${CODE_PATH}] : " code_path 
    CODE_PATH=${code_path:-${CODE_PATH}}
fi

if [[ -z "${DJANGO_PROJECT_NAME}" ]]
then
    PN=$(basename $(dirname $(find ${CODE_PATH} -name "asgi.py")))
    read -p "Enter name of django project, the folder in which wsgi.py resides [${PN}] : " django_project_name
    DJANGO_PROJECT_NAME=${django_project_name:-${PN}}
fi

cat ${SCRIPTS_ROOT}/templates/django/manage.py | envsubst > ${CODE_PATH}/manage.py
cat ${SCRIPTS_ROOT}/templates/django/wsgi.py | envsubst > ${CODE_PATH}/${django_project_name}/wsgi.py