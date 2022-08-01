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

runuser --login ${USER_NAME} -P -c "podman run -dit --secret=MARIADB_ROOT_PASSWORD,type=env --secret=DB_PASSWORD,type=env --name \"${MARIA_CONT_NAME}\" -v ${DB_VOL_NAME}:/var/lib/mysql:Z --pod \"${POD_NAME}\" ${tag}"