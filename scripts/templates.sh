#!/bin/bash

source ${PROJECT_SETTINGS}

for templates in $(find ${CONTAINER_SCRIPTS_ROOT}/containers -type f -name "templates.sh" | sort)
do
    bash "${templates}"
done
