#!/bin/bash

source ${PROJECT_SETTINGS}
source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

if [[ ${DEBUG} == "TRUE" ]]
then
     cp ${CURRENT_DIR}/templates/maria_dev.sh ${CURRENT_DIR}/../image/dockerfile/maria.sh
else
     cp ${CURRENT_DIR}/templates/maria_prod.sh ${CURRENT_DIR}/../image/dockerfile/maria.sh
fi
