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
        echo debug create_containers file listing = $(ls -al "${container}/container/${run_file}.sh")
        if [[ -f "${container}/coontainer/${run_file}.sh" ]]
        then
            bash "${container}/container/${run_file}.sh"
        fi
    done
done
