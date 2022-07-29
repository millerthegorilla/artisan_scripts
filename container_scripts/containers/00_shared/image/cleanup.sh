#!/bin/bash


echo -e "remove all podman images (choose a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) imgs_remove=1; break;;
        No ) imgs_remove=0; break;;
    esac
done

if [[ imgs_remove -eq 1 ]]
then
    IMAGES=$(grep -whorP "(TAG)+=\K.*" ${CONTAINER_SCRIPTS_ROOT}/containers/ | sed s'/\n/ /')
	runuser --login ${USER_NAME} -c "podman rmi ${IMAGES}"
fi

runuser --login ${USER_NAME} -c "podman volume prune -f"