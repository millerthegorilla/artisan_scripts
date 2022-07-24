#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${SCRIPTS_ROOT}/options

function get_variables_and_make_project_file()
{
    set -a
        CONTAINER_SCRIPTS_ROOT="${SCRIPTS_ROOT}/container_scripts"
    set +a
    
    source ${CONTAINER_SCRIPTS_ROOT}/.questions.sh
    
    for container in $(ls -d ${CONTAINER_SCRIPTS_ROOT}/containers/*)
    do
        source ${container}/variables/questions.sh
    done
 
} # end of get_variables_and_make_project_file

echo -e "Enter absolute filepath of project variables or press enter to accept default.\n \
         If the default does not exist, then you can enter the variables manually..."
read -p ": " -e PROJECT_FILE

if [[ -n ${PROJECT_FILE} && -f ${PROJECT_FILE} ]];
then
    cp ${PROJECT_FILE} ./.proj
elif [[ -n ${DEFAULT_PROJECT_FILE} && -f ${DEFAULT_PROJECT_FILE} ]];
then
    cp ${DEFAULT_PROJECT_FILE} ./.proj
else
    get_variables_and_make_project_file
fi