#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

for netfile in $(find ${CONTAINER_SCRIPTS_ROOT}/containers -type f -name "net.sh" | sort)
do
    /bin/bash "${netfile}"
done