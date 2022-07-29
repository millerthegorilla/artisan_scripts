#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

# REMOVE TEMPLATED FILES
if [[ ${DEBUG} == "FALSE" ]];
then
   rm settings/gunicorn.conf.py
else
   rm ${SCRIPTS_ROOT}/dockerfiles/dockerfile_django_dev
fi

if [[ ! -n "$DJANGO_PROJECT_NAME" ]]
then
    if [ -n ${CODE_PATH} ];
    then
        PN=$(basename $(dirname $(find ${CODE_PATH} -name "asgi.py")))
    fi
    read -p "enter the name of the django project folder (where wsgi.py resides) [${PN}] : " -e DJANGO_PROJECT_NAME
    DJANGO_PROJECT_NAME=${DJANGO_PROJECT_NAME:-${PN}}
fi

if [ -n ${CODE_PATH} ];
then
    if [[ ${DEBUG} == "TRUE" ]]
    then
        rm ${CODE_PATH}/manage.py
        rm ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py
    else
        rm -rf ${CODE_PATH}/manage.py ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py
    fi
fi

# REMOVE MEDIA FILES AND DIRECTORIES
echo -e "remove media files (choose a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) mediafiles_remove=1; break;;
        No ) mediafiles_remove=0; break;;
    esac
done

if [[ ${mediafiles_remove} -eq 1 ]]
then
    if [[ ${DEBUG} == "TRUE" ]]
    then
        if [ -n ${CODE_PATH} ];
        then  
            rm -rf ${CODE_PATH}/media/cache
            rm -rf ${CODE_PATH}/media/uploads
        fi
    else
        rm -rf ${DJANGO_HOST_MEDIA_VOL}/media/cache/*
        rm -rf ${DJANGO_HOST_MEDIA_VOL}/media/uploads/*
    fi
fi