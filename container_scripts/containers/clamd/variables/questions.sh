#!/bin/bash

echo debug 1 clamd questions.sh local_settings_file = ${LOCAL_SETTINGS_FILE}

LOCAL_SETTINGS_FILE=$(source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh ${BASH_SOURCE} ${LOCAL_SETTINGS_FILE})

# CLAM_CONT_NAME
CLAM_CONT_NAME="clamav_cont"

echo "CLAM_CONT_NAME=${CLAM_CONT_NAME}" >> ${LOCAL_SETTINGS_FILE}

# CLAM_IMAGE
CLAM_IMAGE=$(get_tag)

echo "CLAM_IMAGE=${CLAM_IMAGE}" >> ${LOCAL_SETTINGS_FILE}