#!/bin/bash

L_S_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh

# CLAM_CONT_NAME
CLAM_CONT_NAME="clamav_cont"

echo "CLAM_CONT_NAME=${CLAM_CONT_NAME}" >> ${L_S_FILE}

# CLAM_IMAGE
CLAM_IMAGE=$(get_tag $BASH_SOURCE)

echo "CLAM_IMAGE=${CLAM_IMAGE}" >> ${L_S_FILE}