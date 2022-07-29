#!/bin/bash

source ${PROJECT_SETTINGS}

echo ${CURRENT_DIR}

if [[ ${DEBUG} == "TRUE" ]]
then
    cat ${CURRENT_DIR}/templates/maria_dev.sh | envsubst '$db_user:$db_host:$db_name' > ${CURRENT_DIR}/dockerfiles/maria.sh
 else
    cat ${CURRENT_DIR}/templates/maria_prod.sh | envsubst '$db_user:$db_host:$db_name' > ${CURRENT_DIR}/dockerfiles/maria.sh
fi