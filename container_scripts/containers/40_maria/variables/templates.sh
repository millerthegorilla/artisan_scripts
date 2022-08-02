#!/bin/bash

source ${PROJECT_SETTINGS}
source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

# if [[ ${DEBUG} == "TRUE" ]]
# then
#     cat ${CURRENT_DIR}/templates/maria_dev.sh | envsubst > ${CURRENT_DIR}/../image/dockerfile/maria.sh
#  else
#     cat ${CURRENT_DIR}/templates/maria_prod.sh | envsubst > ${CURRENT_DIR}/../image/dockerfile/maria.sh
# fi