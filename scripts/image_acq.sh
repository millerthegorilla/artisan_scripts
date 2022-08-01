#!/bin/bash

source ${PROJECT_SETTINGS}

declare –a pids=()

for image_src in $(find ${CONTAINER_SCRIPTS_ROOT}/containers -type f -name "source.sh" | sort)
do
    source ${image_src}
    runuser ${USER_NAME} -l -c "podman image exists ${TAG}"
    if [[ ! $? -eq 0 ]]
    then
        runuser ${USER_NAME} -l -c "podman pull ${SOURCE} &"
        pids+=($!)
    fi
done

for pid in "${pids[@]}"
do
     wait ${pid}
done