#!/bin/bash

source ${PROJECT_SETTINGS}

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

SYSTEMD_UNIT_DIR="${CURRENT_DIR}/unit_files"

# POD MUST BE RUNNING WITH ALL CONTAINERS RUNNING INSIDE
runuser --login "${USER_NAME}" -c "mkdir ${USER_DIR}/systemd; cd ${USER_DIR}/systemd && podman generate systemd --new --name --files ${POD_NAME}"

# copy gitignore into empty dir
cp ${CURRENT_DIR}/templates/systemd_git_ignore ${SYSTEMD_UNIT_DIR}/.gitignore
cp ${USER_DIR}/systemd/* ${SYSTEMD_UNIT_DIR}
chown -R ${USER}:${USER} ${SYSTEMD_UNIT_DIR}
rm -rf ${USER_DIR}/systemd
