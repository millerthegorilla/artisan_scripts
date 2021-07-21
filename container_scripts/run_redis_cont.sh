#!/bin/bash

echo -e "run_redis_cont.sh"

source ${SCRIPTS_ROOT}/.env

podman run -dit --pod ${POD_NAME} --name ${REDIS_CONT_NAME} ${REDIS_IMAGE}
