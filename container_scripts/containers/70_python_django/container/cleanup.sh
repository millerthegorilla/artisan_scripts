#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

# REMOVE TEMPLATED FILES
if [[ ${DEBUG} == "FALSE" ]];
then
    if [[ -f ${CONTAINER_SCRIPTS_ROOT}/settings/gunicorn.conf.py ]];
    then
        rm ${CONTAINER_SCRIPTS_ROOT}/settings/gunicorn.conf.py
    fi
else
    if [[ -f ${CURRENT_DIR}/../image/dockerfile/dockerfile ]];
    then
        rm ${CURRENT_DIR}/../image/dockerfile/dockerfile
    fi
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

if [[ -d ${CODE_PATH]} ]];
then
    find ${CODE_PATH} -type l -exec rm {} +
fi