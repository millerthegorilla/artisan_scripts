#!/bin/bash

# called by {SCRIPTS_ROOT}/scripts/create_all.sh

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

function settings_copy()
{
    echo "Please select the settings file from the list"

    files=$(ls ${CONTAINER_SCRIPTS_ROOT}/settings/${1})
    i=1

    for j in $files
    do
    echo "$i.$j"
    file[i]=$j
    i=$(( i + 1 ))
    done

    echo "Enter number"
    read input
    cp ${CONTAINER_SCRIPTS_ROOT}/settings/${1}/${file[${input}]} ${SCRIPTS_ROOT}/settings/settings.py
}

if [[ "${DEBUG}" == "TRUE" ]] 
then
    settings_copy "development"
else
    settings_copy "production"
fi