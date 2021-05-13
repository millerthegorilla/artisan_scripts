#!/bin/bash

if [[ -e ${SCRIPTS_ROOT}/.archive ]]
then
    source ${SCRIPTS_ROOT}/.archive
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

if [[ ${DEBUG} == "TRUE" ]]
then
	echo "this is a development setup - manage.py should reload automatically on file changes."
else
	podman exec -it $DJANGO_CONT_NAME bash -c "supervisorctl reload gunicorn"
fi

####   need to reload nginx - try svscanctl inside swag container.