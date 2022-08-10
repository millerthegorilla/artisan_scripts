#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

L_S_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/containers/00_shared/variables/settings.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

# CLAM_CONT_NAME
CLAM_CONT_NAME="clamav_cont"

echo "CLAM_CONT_NAME=${CLAM_CONT_NAME}" >> ${L_S_FILE}

# CLAM_IMAGE
CLAM_IMAGE=$(get_tag ${CURRENT_DIR})

echo "CLAM_IMAGE=${CLAM_IMAGE}" >> ${L_S_FILE}