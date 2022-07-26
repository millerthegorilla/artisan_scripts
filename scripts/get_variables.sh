#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

function get_variables_and_make_project_file()
{
    source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/local_settings.sh
    
    if [[ -f ${SCRIPTS_ROOT/.PROJECT_SETTINGS} ]]
    then
        if grep -q '[^[:space:]]' ${SCRIPTS_ROOT}/.PROJECT_SETTINGS;
        then
            echo "local .PROJECT_SETTINGS exists and is not empty"
            echo "Moving it to PROJECT_SETTINGS_OLD"
            mv ${SCRIPTS_ROOT}/.PROJECT_SETTINGS ${SCRIPTS_ROOT}/settings_files/PROJECT_SETTINGS_OLD.$(date +%d-%m-%y_%T)
        fi
    fi

    # root questions including questions shared by containers
    local_settings_file=$(local_settings ${LOCAL_SETTINGS_FILE} "${CONTAINER_SCRIPTS_ROOT}/questions.sh"  | tee /dev/tty | tail -n 1 > /dev/null 2>&1)
    echo debug 1 in get_variables 25 local_settings_file is $local_settings_file
    source ${CONTAINER_SCRIPTS_ROOT}/questions.sh  ${local_settings_file}
    cat ${local_settings_file} > ${SCRIPTS_ROOT}/.PROJECT_SETTINGS

    # container specific questions
    for container in $(ls -d ${CONTAINER_SCRIPTS_ROOT}/containers/*)
    do
        echo debug 1 local_settings_file is ${LOCAL_SETTINGS_FILE}
        local_settings_file=$(local_settings ${LOCAL_SETTINGS_FILE} "${container}/variables/questions.sh")
        source ${container}/variables/questions.sh ${local_settings_file}
        cat ${local_settings_file} >> ${SCRIPTS_ROOT}/.PROJECT_SETTINGS
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
        cp ${SCRIPTS_ROOT}/.PROJECT_SETTINGS ${SCRIPTS_ROOT}/settings_files/PROJECT_SETTINGS.PROJECT_NAME.$(date +%d-%m-%y_%T)
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