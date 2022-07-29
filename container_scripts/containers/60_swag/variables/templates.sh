#!/bin/bash

source ${PROJECT_SETTINGS}

if [[ ${DEBUG} == "FALSE" ]]
then
    
    if [[ ${tldomain} == "TRUE" ]]
    then
        cat ${CURRENT_DIR}/templates/nginx/default_tld | envsubst '$tl_domain:$duckdns_domain' > ${CURRENT_DIR}/../image/dockerfiles/swag/default
    else
        cat ${CURRENT_DIR}/templates/nginx/default | envsubst '$duckdns_domain' > ${CURRENT_DIR}/../image/dockerfiles/swag/default
    fi
fi