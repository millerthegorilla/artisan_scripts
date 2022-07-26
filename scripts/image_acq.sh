#!/bin/bash

source ${PROJECT_SETTINGS}

for image_src in $(find {CONTAINER_SCRIPTS_ROOT}/containers -type f -name "source.sh" | sort)
do
    source ${SCRIPTS_ROOT}/${image_src}
    runuser ${USER_NAME} -l -c "podman image exists ${TAG}"
    if [[ ! $? -eq 0 ]]
    then
        runuser ${USER_NAME} -l -c "podman pull ${SOURCE} &"
    fi
done
wait