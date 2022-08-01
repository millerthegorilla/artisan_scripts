#!/bin/bash

source ${PROJECT_SETTINGS}

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

if [[ ${DEBUG} == "FALSE" ]]
then
    
    if [[ ${tldomain} == "TRUE" ]]
    then
        cat ${CURRENT_DIR}/templates/nginx/default_tld | envsubst '$tl_domain:$duckdns_domain' > ${CURRENT_DIR}/../image/dockerfile/swag/default
    else
        cat ${CURRENT_DIR}/templates/nginx/default | envsubst '$duckdns_domain' > ${CURRENT_DIR}/../image/dockerfile/swag/default
    fi
fi