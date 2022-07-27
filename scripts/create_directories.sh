#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

for dirfile in $(find {CONTAINER_SCRIPTS_ROOT}/containers -type f -name "directories.sh" | sort)
do
    /bin/bash ${SCRIPTS_ROOT}/${dirfile}
done