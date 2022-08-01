#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

IFS=',' read -r -a run_files <<< "${RUN_FILES}"

for container in $(ls -d ${CONTAINER_SCRIPTS_ROOT}/containers/*)
do
    for run_file in "${run_files[@]}"
    do
        if [[ -f "${container}/coontainer/${run_file}.sh" ]]
        then
            echo debug 1 create_containers.sh inside if 
            bash "${container}/container/${run_file}.sh"
            echo debug 2 create_containers output = $?
        fi
    done
done
