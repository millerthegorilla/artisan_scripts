#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

function get_variables_and_make_project_file()
{
    source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/local_settings.sh

    function get_variables()
    {
        for container in $(ls -d ${1})
        do
            local_settings_file=$(local_settings ${LOCAL_SETTINGS_FILE} "${container}/variables/questions.sh" | tail -n 1)
            bash ${container}/variables/questions.sh ${local_settings_file}
            cat ${local_settings_file} >> ${PROJECT_SETTINGS}
            unset local_settings_file
        done
    }

    get_variables "${CONTAINER_SCRIPTS_ROOT}/containers/*"
    get_variables "${CONTAINER_SCRIPTS_ROOT}/pods/*"

    echo -e "Do you want to save your settings as a settings file? : "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) SAVE_SETTINGS="TRUE"; break;;
            No ) SAVE_SETTINGS="FALSE"; break;;
        esac
    done    

    if [[ SAVE_SETTINGS == "TRUE" ]]
    then
        cp ${PROJECT_SETTINGS} ${SCRIPTS_ROOT}/settings_files/PROJECT_SETTINGS.${PROJECT_NAME}.$(date +%d-%m-%y_%T)
    fi
}

function make_project_settings()
{
    touch ${PROJECT_SETTINGS}
    chown root:root ${PROJECT_SETTINGS}
    chmod 0600 ${PROJECT_SETTINGS}
}

function check_for_project_settings()
{
    if [[ -f ${PROJECT_SETTINGS} ]]
    then
        if grep -q '[^[:space:]]' ${PROJECT_SETTINGS};
        then
            echo "local .PROJECT_SETTINGS exists and is not empty"
            echo "Moving it to PROJECT_SETTINGS_OLD"
            mv ${PROJECT_SETTINGS} ${SCRIPTS_ROOT}/settings_files/PROJECT_SETTINGS_OLD.$(date +%d-%m-%y_%T)
            make_project_settings
        fi
    fi
}

check_for_project_settings

echo -e "Enter absolute filepath of project settings or press enter to accept default.\n \
If the default does not exist, then you can enter the variables manually..."

read -p ": " -e PROJECT_FILE

if [[ -n ${PROJECT_FILE} && -f ${PROJECT_FILE} ]];
then
    project_settings=${PROJECT_FILE}
elif [[ -n ${DEFAULT_PROJECT_FILE} && -f ${DEFAULT_PROJECT_FILE} ]];
then
    project_settings=${DEFAULT_PROJECT_FILE}
else
    get_variables_and_make_project_file
fi

if [[ "${project_settings}" != "${SCRIPTS_ROOT}/.PROJECT_SETTINGS" ]]
then
    cat ${project_settings} >> ${PROJECT_SETTINGS}
fi