#!/bin/bash

L_S_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/containers/00_shared/variables/settings.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

# REDIS_CONT_NAME

REDIS_CONT_NAME="redis_cont"

echo "REDIS_CONT_NAME=${REDIS_CONT_NAME}" >> ${L_S_FILE}

# REDIS_IMAGE
REDIS_IMAGE=$(get_tag ${CURRENT_DIR})

echo "REDIS_IMAGE=${REDIS_IMAGE}" >> ${L_S_FILE}