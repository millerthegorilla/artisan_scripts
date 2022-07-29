#!/bin/bash

###  This script will rebuild manage.py and wsgi.py in case a git pull of the main django_artisan code base
###  removes them.
if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

cat ${CURRENT_DIR}/../variables/templates/django/manage.py | envsubst > ${CODE_PATH}/manage.py
cat ${CURRENT_DIR}/../templates/django/wsgi.py | envsubst > ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py
chown ${USER_NAME}:${USER_NAME} ${CODE_PATH}/manage.py ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py
runuser --login ${USER_NAME} -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -e DJANGO_PROJECT_NAME=${django_project_name} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan /opt/${PROJECT_NAME}/manage.py /opt/${PROJECT_NAME}/${DJANGO_PROJECT_NAME}/wsgi.py\""