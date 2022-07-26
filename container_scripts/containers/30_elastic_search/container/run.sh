#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

runuser --login ${USER_NAME} -P -c "podman run -dit --name=${ELASTIC_CONT_NAME} --pod=$POD_NAME ${AUTO_UPDATES} -e discovery.type=\"single-node\" -e ES_JAVA_OPTS=\"-Xms512m -Xmx512m\" ${ELASTIC_IMAGE}"
