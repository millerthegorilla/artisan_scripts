#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

function run_files()
{
    for file in $(find ${CONTAINER_SCRIPTS_ROOT}/containers -type f -name "${1}.sh" | sort)
    do
        /bin/bash "${file}"
    done
}

run_files=${RUN_FILES}

for file in ${run_files[@]}
do
    echo debug 1 create_all.sh file=${file}
    run_files ${file}
done