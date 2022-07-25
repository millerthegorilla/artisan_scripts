#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

echo debug 1 get_variables CONT_SCRIPT_ROOT = ${CONTAINER_SCRIPTS_ROOT}

function get_variables_and_make_project_file()
{
    source ${CONTAINER_SCRIPTS_ROOT}/questions.sh
    
    for container in $(ls -d ${CONTAINER_SCRIPTS_ROOT}/containers/*)
    do
        source ${container}/variables/questions.sh
    done
    if [[ -f ${SCRIPTS_ROOT/.PROJECT_SETTINGS} ]]
    then
        if grep -q '[^[:space:]]' ${SCRIPTS_ROOT}/.PROJECT_SETTINGS;
        then
            echo "local .PROJECT_SETTINGS exists and is not empty"
            echo "Moving it to PROJECT_SETTINGS_OLD"
            mv ${SCRIPTS_ROOT}/.PROJECT_SETTINGS ${SCRIPTS_ROOT}/PROJECT_SETTINGS_OLD
        fi
    fi

    cd ${CONTAINER_SCRIPTS};
    cat ${LOCAL_SETTINGS_FILE} > ${SCRIPTS_ROOT}/.PROJECT_SETTINGS

    for container in $(ls -d ${CONTAINER_SCRIPTS_ROOT}/containers/*)
    do
        cd ${container}/variables;
        cat ${LOCAL_SETTINGS_FILE} >> ${SCRIPTS_ROOT}/.PROJECT_SETTINGS
    done

    echo -e "Do you want to save your settings as a settings file? : "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) SAVE_SETTINGS="TRUE"; break;;
            No ) SAVE_SETTINGS="FALSE"; break;;
        esac
    done    

    if [[ SAVE_SETTINGS == "TRUE" ]]
    then
        cp ${SCRIPTS_ROOT}/.PROJECT_SETTINGS PROJECT_SETTINGS.PROJECT_NAME.$(date +%d-%m-%y_%T)
    fi

    PROJECT_SETTINGS=${SCRIPTS_ROOT}/.PROJECT_SETTINGS
}

echo -e "Enter absolute filepath of project settings or press enter to accept default.\n \
If the default does not exist, then you can enter the variables manually..."

read -p ": " -e PROJECT_FILE

if [[ -n ${PROJECT_FILE} && -f ${PROJECT_FILE} ]];
then
    PROJECT_SETTINGS=${PROJECT_FILE}
elif [[ -n ${DEFAULT_PROJECT_FILE} && -f ${DEFAULT_PROJECT_FILE} ]];
then
    PROJECT_SETTINGS=${DEFAULT_PROJECT_FILE}
else
    get_variables_and_make_project_file
fi

-a
PROJECT_SETTINGS=${PROJECT_SETTINGS}
+a