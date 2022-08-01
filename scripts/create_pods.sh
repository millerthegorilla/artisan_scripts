#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

IFS=',' read -r -a run_files <<< "${RUN_FILES}"

for pod in $(ls -d ${CONTAINER_SCRIPTS_ROOT}/pods/*)
do
    for run_file in "${run_files[@]}"
    do
        if [[ -f "${pod}/container/${run_file}.sh" ]]
        then
            bash "${pod}/container/${run_file}.sh"
        fi
    done
done
