#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

function run_files()
{
	fn="${1}.sh"
	echo ${fn}
	for container_file in $(find ${CONTAINER_SCRIPTS_ROOT}/containers -type f -name "${fn}" | sort)
    do
	echo debug 6 create_all.sh file is ${container_file}
        /bin/bash "${container_file}"
    done
}


echo debug 2 create_all.sh run_files =${RUN_FILES}
echo debug 3 create_all.sh CONTAINER_SCRIPTS_ROOT =${CONTAINER_SCRIPTS_ROOT}

IFS=',' read -r -a run_files <<< "${RUN_FILES}"

echo debug 4 create_all.sh run_files = ${run_files[@]}
for run_file in "${run_files[@]}"
do
    echo debug 5 create_all.sh file is  ${run_file}
    run_files ${run_file}
done
