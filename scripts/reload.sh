#!/bin/bash

if [[ -e ${SCRIPTS_ROOT}/.archive ]]
then
    source ${SCRIPTS_ROOT}/.archive
fi

if [[ -e ${SCRIPTS_ROOT}/.proj ]]
then
    source ${SCRIPTS_ROOT}/.proj
fi

if [[ -z "${DEBUG}" ]]
then
	echo -e "Is the running setup a development setup? : "
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) DEBUG="TRUE"; break;;
	        No ) DEBUG="FALSE"; break;;
	    esac
	done
fi

if [[ -z "${DJANGO_CONT_NAME}" ]]
then
	read -p "enter the name of the django container : " DJANGO_CONT_NAME
fi

if [[ -z "${PROJECT_NAME}" ]]
then
	read -p "Enter artisan scripts project name, as in /etc/opt/*PROJECT_NAME*/settings etc [${PROJECT_NAME}] : " project_name
    PROJECT_NAME=${project_name:-${PROJECT_NAME}}
fi

if [[ ${DEBUG} == "TRUE" ]]
then
	echo "this is a development setup - manage.py should reload automatically on file changes."
else
	 runuser --login ${USER_NAME} -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"su artisan -c \"killall5 gunicorn && gunicorn -c /etc/opt/${PROJECT_NAME}/settings/gunicorn.conf.py\"\""
fi

####   need to reload nginx - try svscanctl inside swag container.