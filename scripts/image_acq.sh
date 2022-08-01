#!/bin/bash

source ${PROJECT_SETTINGS}

for image_src in $(find ${CONTAINER_SCRIPTS_ROOT}/containers -type f -name "source.sh" | sort)
do
    source ${image_src}
    if ! runuser ${USER_NAME} -l -c "podman image exists ${TAG}";
    then
	    echo "pulling ${TAG}"
        runuser ${USER_NAME} -l -c "podman pull ${SOURCE}"
    fi
done
