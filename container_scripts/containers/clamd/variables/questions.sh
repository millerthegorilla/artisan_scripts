#!/bin/bash

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

# CLAM_CONT_NAME
CLAM_CONT_NAME="clamav_cont"

echo "CLAM_CONT_NAME=${CLAM_CONT_NAME}" >> ${LOCAL_SETTINGS_FILE}

# CLAM_IMAGE
CLAM_IMAGE="docker.io/tiredofit/clamav:latest"

echo "CLAM_IMAGE=${CLAM_IMAGE}" >> ${LOCAL_SETTINGS_FILE}