#!/bin/bash

source ${PROJECT_SETTINGS}

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

SYSTEMD_UNIT_DIR="${CURRENT_DIR}/unit_files"

if [[ -d ${SYSTEMD_UNIT_DIR} ]];
then
	if [[ $(ls -A ${SYSTEMD_UNIT_DIR} ]];
	then
		echo -e "systemd unit_file directory is not empty.  Moving systemd unit_file directory."
		mv ${SYSTEMD_UNIT_DIR} ${SYSTEMD_UNIT_DIR}.$(date +%d-%m-%y_%T)
		mkdir ${SYSTEMD_UNIT_DIR}
	fi
fi

if [[ ${DEBUG} == "TRUE" ]]
then
	if [[ $(systemctl get-default) == "graphical.target" && $(id -u ${USER_NAME}) -ge 1000 ]]
	then 
    	cat ${SCRIPTS_ROOT}/templates/systemd/manage_start_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/manage_start.service 
    	cat ${SCRIPTS_ROOT}/templates/systemd/qcluster_start_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/qcluster_start.service 
    elif [[ $(systemctl get-default) == "graphical.target" && $(id -u ${USER_NAME}) -le 999 || $(systemctl get-default) == "multi-user.target" ]]
    then
        cat ${SCRIPTS_ROOT}/templates/systemd/manage_start_non_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/manage_start.service
    	cat ${SCRIPTS_ROOT}/templates/systemd/qcluster_start_non_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/qcluster_start.service
    fi
else
    cat ${SCRIPTS_ROOT}/templates/systemd/qcluster_start_non_graphical.service | envsubst > ${SYSTEMD_UNIT_DIR}/qcluster_start.service 
fi