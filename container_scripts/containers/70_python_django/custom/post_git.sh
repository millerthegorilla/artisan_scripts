#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /opt/${PROJECT_NAME}&& find /opt/${PROJECT_NAME} -type d -exec chmod 0550 {} + && find /opt/${PROJECT_NAME} -type f -exec chmod 0440 {} +\""
runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /etc/opt/${PROJECT_NAME} && find /etc/opt/${PROJECT_NAME} -type f -exec chmod 0440 {} + && find /etc/opt/${PROJECT_NAME} -type d -exec chmod 0550 {} +\""
