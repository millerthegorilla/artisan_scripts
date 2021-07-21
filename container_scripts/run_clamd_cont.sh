#!/bin/bash
echo -e "run_clamd_cont.sh"

source ${SCRIPTS_ROOT}/.env

podman run -dit --pod ${POD_NAME} --name ${CLAM_CONT_NAME} ${CLAM_IMAGE}

