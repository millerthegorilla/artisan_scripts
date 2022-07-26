#!/bin/bash

LOCAL_SETTINGS_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh

# REDIS_CONT_NAME

REDIS_CONT_NAME="redis_cont"

echo "REDIS_CONT_NAME=${REDIS_CONT_NAME}" >> ${LOCAL_SETTINGS_FILE}

# REDIS_IMAGE
REDIS_IMAGE=$(get_tag $BASH_SOURCE)

echo "REDIS_IMAGE=${REDIS_CONT_NAME}" >> ${LOCAL_SETTINGS_FILE}