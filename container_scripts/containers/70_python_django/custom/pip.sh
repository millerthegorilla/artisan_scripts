#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"runuser -s /bin/bash artisan -c 'source /home/artisan/django_venv/bin/activate && pip ${COMMANDS}'\""
