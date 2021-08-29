#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "run_elastic_search_cont.sh"

source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.proj

runuser --login ${USER_NAME} -P -c "podman run -dit --name=$ELASTIC_CONT_NAME --pod=$POD_NAME ${UPDATES} -e discovery.type=\"single-node\" -e ES_JAVA_OPTS=\"-Xms512m -Xmx512m\" --restart unless-stopped $ELASTIC_IMAGE"
