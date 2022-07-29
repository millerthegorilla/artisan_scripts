#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

COMMANDS="$*"
runuser --login ${USER_NAME} -c "podman exec -e COMMANDS=\"$*\" -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH=\"/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/\" -it ${DJANGO_CONT_NAME} bash -c \"cd opt/${PROJECT_NAME}; python manage.py ${COMMANDS}\""
