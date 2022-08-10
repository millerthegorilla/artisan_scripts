#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

tag=$(get_tag ${CURRENT_DIR})

runuser --login ${USER_NAME} -P -c "podman run -dit --name \"${MARIA_CONT_NAME}\" -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=TRUE -v ${DB_VOL}:/var/lib/mysql:Z --pod \"${POD_NAME}\" ${tag}"