#!/bin/bash

for image_src in $(find {CONTAINER_SCRIPTS_ROOT}/containers -type f -name "source.sh")
do
    source $image_src
    podman image exists $TAG
    if [[ ! $? -eq 0 ]]
    then
        podman pull SOURCE &
    fi
done
wait