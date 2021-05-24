#!/bin/bash

if [[ -z "${DEBUG}" ]]
then
    echo -e "\nIs this development ie debug? : "
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) DEBUG="TRUE"; break;;
            No ) DEBUG="FALSE"; break;;
        esac
    done
fi

function settings_copy()
{
    echo "Please select the settings file from the list"

    files=$(ls ${SCRIPTS_ROOT}/settings/${1})
    i=1

    for j in $files
    do
    echo "$i.$j"
    file[i]=$j
    i=$(( i + 1 ))
    done

    echo "Enter number"
    read input
    cp ${SCRIPTS_ROOT}/settings/${1}/${file[${input}]} ${SCRIPTS_ROOT}/settings/settings.py
}

if [[ ${DEBUG} == "TRUE" ]]   ## TODO function 
then
    settings_copy "development"
else
    settings_copy "production"
fi

if [[ -f "${SCRIPTS_ROOT}/.proj" ]]
then
    source ${SCRIPTS_ROOT}/.proj
fi

if [[ -n "${PROJECT_NAME}" ]]
then
    echo -e "\nProject name is ${PROJECT_NAME}"
else
    echo -e "\n*** PROJECT NAME IS NOT SET ***"
fi

if [[ -z "${PROJECT_NAME}" ]]
then
    read -p "Enter your project name - this is used as a directory name, so must be conformant to bash requirements [${PROJECT_NAME}] : " pn

    project_name=${pn:-${PROJECT_NAME}}
else
    project_name=$PROJECT_NAME
fi

if [[ -z "$CODE_PATH" ]]
then
    read -p 'Path to code (the django_artisan folder where manage.py resides) : ' CODE_PATH
else
    echo -e "\nCODE PATH is ${CODE_PATH}\n"
fi

set -a
DEBUG=${DEBUG}
CODE_PATH=${CODE_PATH}
PROJECT_NAME=${project_name}
set +a

${SCRIPTS_ROOT}/scripts/get_variables.sh

set -a
source ${SCRIPTS_ROOT}/.env
set +a

echo -e "\n" >> ${SCRIPTS_ROOT}/.archive
echo CURRENT_SETTINGS=${file[${input}]} >> .archive 
echo SWAG_CONT_NAME=${SWAG_CONT_NAME} >> ${SCRIPTS_ROOT}/.archive
echo DJANGO_CONT_NAME=${DJANGO_CONT_NAME} >> ${SCRIPTS_ROOT}/.archive
echo CODE_PATH=${CODE_PATH} >> ${SCRIPTS_ROOT}/.archive

if [[ ${DEBUG} == "TRUE" ]]
then
   podman pod create --name ${POD_NAME} -p 127.0.0.1:8000:8000
else
   podman pod create --name ${POD_NAME} -p ${PORT1_DESCRIPTION} -p ${PORT2_DESCRIPTION} # --dns-search=${POD_NAME} --dns-opt=timeout:30 --dns-opt=attempts:5
fi

if [[ ${DEBUG} == "FALSE" ]]
then
   ${SCRIPTS_ROOT}/container_scripts/run_duckdns_cont.sh
fi

${SCRIPTS_ROOT}/container_scripts/run_clamd_cont.sh
${SCRIPTS_ROOT}/container_scripts/run_redis_cont.sh
${SCRIPTS_ROOT}/container_scripts/run_elastic_search_cont.sh
${SCRIPTS_ROOT}/container_scripts/run_maria_cont.sh

if [[ ${DEBUG} == "FALSE" ]]
then
   ${SCRIPTS_ROOT}/container_scripts/run_swag_cont.sh
fi

${SCRIPTS_ROOT}/container_scripts/run_django_cont.sh

## systemd generate files

echo -e "Generate and install systemd --user unit files? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) SYSD="TRUE"; break;;
        No ) SYSD="FALSE"; break;;
    esac
done

if [[ ${SYSD} == "TRUE" ]]
then
    cd ${SCRIPTS_ROOT}/systemd/   ## DIRECTORY CHANGE HERE

    podman generate systemd --files ${POD_NAME}
    set -a
     django_service=$(cat .django_container_id)
     django_cont_name=${DJANGO_CONT_NAME}
     project_name=${PROJECT_NAME}
     terminal_cmd=${TERMINAL_CMD}
    set +a

    ## TEMPLATE
    if [[ ${DEBUG} == "TRUE" ]]
    then
        cat ${SCRIPTS_ROOT}/templates/manage_start.service | envsubst > ${SCRIPTS_ROOT}/systemd/manage_start.service 
    else
        cat ${SCRIPTS_ROOT}/templates/gunicorn_start.service | envsubst > ${SCRIPTS_ROOT}/systemd/gunicorn_start.service 
    fi
    
    source ${SCRIPTS_ROOT}/scripts/utils.sh
    read -p "Enter the name of your sudo user account : " SUNAME
    
    super_access "SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_init.sh"

    systemctl --user enable $(ls -p ${SCRIPTS_ROOT}/systemd | grep -v / | tr '\n' ' ')

    cd ${SCRIPTS_ROOT}   ## DIRECTORY CHANGE HERE
fi

rm .env