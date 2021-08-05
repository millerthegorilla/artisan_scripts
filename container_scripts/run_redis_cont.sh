#!/bin/bash

echo -e "run_redis_cont.sh"

source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.proj

runuser --login ${USER_NAME} -P -c "podman run -dit --pod ${POD_NAME} --name ${REDIS_CONT_NAME} ${REDIS_IMAGE}"
