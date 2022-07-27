#!/bin/bash

L_S_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/containers/00_shared/variables/settings.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh

# DUCKDNS_DOMAIN
read -p "Duckdns domain : [ ${SITE_ADDRESS} ]" DUCKDNS_DOMAIN
DUCKDNS_DOMAIN=${DUCKDNS_DOMAIN:-${SITE_ADDRESS}}

echo "DUCKDNS_DOMAIN=${DUCKDNS_DOMAIN}" >> ${L_S_FILE}

# DUCKDNS_CONT_NAME
DUCKDNS_CONT_NAME="duckdns_cont"

echo "DUCKDNS_CONT=${DUCKDNS_CONT}" >> ${L_S_FILE}

# DUCKDNS_IMAGE
DUCKDNS_IMAGE=$(get_tag $BASH_SOURCE)

echo "DUCKDNS_IMAGE=${DUCKDNS_IMAGE}" >> ${L_S_FILE}