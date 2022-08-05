#!/bin/bash

set -a
source ${PROJECT_SETTINGS}
set +a

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

SYSTEMD_UNIT_DIR="${CURRENT_DIR}/unit_files"

if [[ ! -d ${SYSTEMD_UNIT_DIR} ]];
then
    mkdir -p ${SYSTEMD_UNIT_DIR};
fi

if ! find ${SYSTEMD_UNIT_DIR} -type f -not -path ${SYSTEMD_UNIT_DIR}/.git_empty_dir;
then
	echo -e "systemd unit_file directory is not empty.  Moving systemd unit_file directory."
	mv ${SYSTEMD_UNIT_DIR} ${SYSTEMD_UNIT_DIR}.$(date +%d-%m-%y_%T)
	mkdir ${SYSTEMD_UNIT_DIR}
fi

if [[ ${DEBUG} == "TRUE" ]]
then
	if [[ $(systemctl get-default) == "graphical.target" && $(id -u ${USER_NAME}) -ge 1000 ]]
	then 
    	cat ${CURRENT_DIR}/templates/manage_start_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/manage_start.service 
    	cat ${CURRENT_DIR}/templates/qcluster_start_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/qcluster_start.service 
    elif [[ $(systemctl get-default) == "graphical.target" && $(id -u ${USER_NAME}) -le 999 || $(systemctl get-default) == "multi-user.target" ]]
    then
        cat ${CURRENT_DIR}/templates/manage_start_non_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/manage_start.service
    	cat ${CURRENT_DIR}/templates/qcluster_start_non_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/qcluster_start.service
    fi
else
    cat ${CURRENT_DIR}/templates/qcluster_start_non_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/qcluster_start.service 
fi
