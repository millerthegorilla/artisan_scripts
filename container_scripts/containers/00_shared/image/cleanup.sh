#!/bin/bash

echo -e "Remove all podman images (choose a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) imgs_remove=1; break;;
        No ) imgs_remove=0; break;;
    esac
done

if [[ imgs_remove -eq 1 ]]
then
    IMAGES=$(grep -whorP "(TAG)+=\K.*" ${CONTAINER_SCRIPTS_ROOT}/containers/ | sed s'/\n/ /')
    echo debug 1 cleanup.sh IMAGES= ${IMAGES}
    for image in ${IMAGES}
    do
	   runuser --login ${USER_NAME} -c "podman rmi ${image}"
    done
fi

runuser --login ${USER_NAME} -c "podman volume prune -f"