#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

function run_files()
{
	for container_file in $(find ${CONTAINER_SCRIPTS_ROOT}/containers -type f -name "${1}.sh" | sort)
    do
        /bin/bash "${container_file}"
    done
}

IFS=',' read -r -a run_files <<< "${RUN_FILES}"

for run_file in "${run_files[@]}"
do
    run_files ${run_file}
done
