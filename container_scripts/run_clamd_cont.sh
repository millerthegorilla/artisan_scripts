#!/bin/bash
echo -e "run_clamd_cont.sh"

source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.proj

runuser --login ${USER_NAME} -P -c "podman run -dit --pod ${POD_NAME} --name ${CLAM_CONT_NAME} --restart unless-stopped ${CLAM_IMAGE}"

