#!/bin/bash

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/local_settings.sh $(dirname ${BASH_SOURCE})

LOCAL_SETTINGS_FILE=$(local_settings ${LOCAL_SETTINGS_FILE})

# CLAM_CONT_NAME
CLAM_CONT_NAME="clamav_cont"

echo "CLAM_CONT_NAME=${CLAM_CONT_NAME}" >> ${LOCAL_SETTINGS_FILE}

# CLAM_IMAGE
CLAM_IMAGE="docker.io/tiredofit/clamav:latest"

echo "CLAM_IMAGE=${CLAM_IMAGE}" >> ${LOCAL_SETTINGS_FILE}