#!/bin/bash

source ${SCRIPTS_ROOT}/options
source ${SCRIPTS_ROOT}/.archive
source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.proj

runuser --login "${USER_NAME}" -c "mkdir ~/systemd; cd ~/systemd && podman generate systemd --new --name --files ${POD_NAME}"
cp ${USER_DIR}/systemd/* ${SCRIPTS_ROOT}/systemd/
rm -rf ${USER_DIR}/systemd

## TEMPLATES
set -a
 django_service=${DJANGO_CONT_NAME}
 django_cont_name=${DJANGO_CONT_NAME}
 project_name=${PROJECT_NAME}
 terminal_cmd=${TERMINAL_CMD}
set +a

if [[ ${DEBUG} == "TRUE" ]]
then
	if [[ $(systemctl get-default) == "graphical.target" && $(id -u ${USER_NAME}) -ge 1000 ]]
	then 
    	cat ${SCRIPTS_ROOT}/templates/systemd/manage_start.service | envsubst > ${SCRIPTS_ROOT}/systemd/manage_start.service 
    	cat ${SCRIPTS_ROOT}/templates/systemd/qcluster_start.service.dev | envsubst > ${SCRIPTS_ROOT}/systemd/qcluster_start.service 
    elif [[ $(systemctl get-default) == "graphical.target" && $(id -u ${USER_NAME}) -le 999 || $(systemctl get-default) == "multi-user.target" ]]
    then
        cat ${SCRIPTS_ROOT}/templates/systemd/service_user_manage_start.service | envsubst > ${SCRIPTS_ROOT}/systemd/manage_start.service
    	cat ${SCRIPTS_ROOT}/templates/systemd/service_user_qcluster_start.service.dev | envsubst > ${SCRIPTS_ROOT}/systemd/qcluster_start.service
    fi
else
    cat ${SCRIPTS_ROOT}/templates/systemd/qcluster_start.service.prod | envsubst > ${SCRIPTS_ROOT}/systemd/qcluster_start.service 
fi
