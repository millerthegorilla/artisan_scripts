#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

bash ${SCRIPTS_ROOT}/scripts/clean_save_settings.sh

for cleanup in $(find ${CONTAINER_SCRIPTS_ROOT}/pods/ -type f -name "cleanup.sh" | sort)
do
    bash ${cleanup}
done

for cleanup in $(find ${CONTAINER_SCRIPTS_ROOT} -type f -name "cleanup.sh" -not -path "container_scripts/pods/*" | sort)
do
    bash ${cleanup}
done