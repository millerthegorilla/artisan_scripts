#!/bin/bash

echo beginning of create_all debug is ${DEBUG}

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

if [[ "${DEBUG}" == "TRUE" ]]   ## TODO function 
then
    settings_copy "development"
else
    settings_copy "production"
fi

if [[ -f "${SCRIPTS_ROOT}/.archive" ]]
then
    source ${SCRIPTS_ROOT}/.archive
fi

if [[ -n "${PROJECT_NAME}" ]]
then
    echo -e "\nProject name is ${PROJECT_NAME}"
else
    echo -e "\n*** PROJECT NAME IS NOT SET ***"
fi

set -a
source ${SCRIPTS_ROOT}/.env
set +a

if [[ ! -f ${HOST_LOG_DIR} ]]
then
    mkdir -p ${HOST_LOG_DIR}
    mkdir ${HOST_LOG_DIR}/django
    mkdir ${HOST_LOG_DIR}/gunicorn
fi

# podman unshare chown 999:0 /etc/opt/${PROJECT_NAME}/database

echo CURRENT_SETTINGS=${file[${input}]} >> .archive 
echo SWAG_CONT_NAME=${SWAG_CONT_NAME} >> ${SCRIPTS_ROOT}/.archive
echo DJANGO_CONT_NAME=${DJANGO_CONT_NAME} >> ${SCRIPTS_ROOT}/.archive
echo CODE_PATH=${CODE_PATH} >> ${SCRIPTS_ROOT}/.archive

if [[ "${DEBUG}" == "TRUE" ]]
then
   podman pod create --name ${POD_NAME} -p 127.0.0.1:8000:8000
else
   podman pod create --name ${POD_NAME} -p ${PORT1_DESCRIPTION} -p ${PORT2_DESCRIPTION} # --dns-search=${POD_NAME} --dns-opt=timeout:30 --dns-opt=attempts:5
fi

if [[ "${DEBUG}" == "FALSE" ]]
then
   ${SCRIPTS_ROOT}/container_scripts/run_duckdns_cont.sh
fi

## TODO change dbvol to env var set in get_variables.sh
## -o uid etc creates euid inside container ie 166355 when viewed on host.
podman volume create dbvol

${SCRIPTS_ROOT}/container_scripts/run_clamd_cont.sh
${SCRIPTS_ROOT}/container_scripts/run_redis_cont.sh
${SCRIPTS_ROOT}/container_scripts/run_elastic_search_cont.sh
${SCRIPTS_ROOT}/container_scripts/run_maria_cont.sh

if [[ "${DEBUG}" == "FALSE" ]]
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

    source ${SCRIPTS_ROOT}/scripts/super_access.sh

    # if [[ $(id ${SYSTEMD_USER_NAME} > /dev/null 2>&1; echo $?) -ne 0 ]]
    # then
    #     echo -e "Error, system account with username ${SYSTEMD_USER_NAME} does not exist!"
    #     exit 1
    # fi

    cd ${SCRIPTS_ROOT}/systemd/ ## DIRECTORY CHANGE HERE

    podman generate systemd --new --name --files ${POD_NAME}
    set -a
     django_service=$(cat .django_container_id)
     django_cont_name=${DJANGO_CONT_NAME}
     project_name=${PROJECT_NAME}
     terminal_cmd=${TERMINAL_CMD}
    set +a

    ## TEMPLATE
    if [[ ${DEBUG} == "TRUE" ]]
    then
        cat ${SCRIPTS_ROOT}/templates/systemd/manage_start.service | envsubst > ${SCRIPTS_ROOT}/systemd/manage_start.service 
        cat ${SCRIPTS_ROOT}/templates/systemd/qcluster_start.service.dev | envsubst > ${SCRIPTS_ROOT}/systemd/qcluster_start.service 
    else
        cat ${SCRIPTS_ROOT}/templates/systemd/qcluster_start.service.prod | envsubst > ${SCRIPTS_ROOT}/systemd/qcluster_start.service 
    fi
    super_access "SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_user_init.sh"

    cd ${SCRIPTS_ROOT}/systemd/
    FILES=*
    for f in ${FILES}
    do
      if [[ -e /etc/systemd/user/${f} ]]
      then
          systemctl --user enable ${f}
      fi
    done

    cd ${SCRIPTS_ROOT}   ## DIRECTORY CHANGE HERE

    # if [[ ${DEBUG} == "FALSE" ]]
    # then
    #     super_access usermod -s /bin/nologin ${USER}
    # fi
fi

rm .env