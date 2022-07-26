#!/bin/bash

L_S_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh

# ELASTIC_CONT_NAME
ELASTIC_CONT_NAME="elastic_cont"

echo "ELASTIC_CONT_NAME=${ELASTIC_CONT_NAME}" >> ${L_S_FILE}

# ELASTIC_IMAGE
ELASTIC_IMAGE=$(get_tag $BASH_SOURCE)

echo "ELASTIC_IMAGE=${ELASTIC_IMAGE}" >> ${L_S_FILE}