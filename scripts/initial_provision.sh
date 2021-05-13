#!/bin/bash



set -a
SCRIPTS_ROOT=${SCRIPTS_ROOT}
set +a

echo -e "\nI will first create the directories.\n"
read -p "Enter the name of your sudo user account : " SUNAME
su ${SUNAME} -c "sudo -S SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/create_directories.sh"

echo -e "\nI will now download and provision container images, if they are not already present.\n"

podman image exists python:latest
if [[ ! $? -eq 0 ]]
then
	podman pull docker.io/library/python:latest &
fi
podman image exists elasticsearch:7.11.2
if [[ ! $? -eq 0 ]]
then
	podman pull docker.io/library/elasticsearch:7.11.2 &
fi
podman image exists mariadb:10.5.9
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/library/mariadb:10.5.9 &
fi
podman image exists redis:6.2.2-buster
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/library/redis:6.2.2-buster &
fi
podman image exists docker-clamav:latest
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/mkodockx/docker-clamav:latest &
fi
podman image exists duckdns:latest
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/linuxserver/duckdns:latest &
fi
podman image exists swag:1.13.0-ls46
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/linuxserver/swag:version-1.14.0 &
fi

wait

podman image exists python:django
if [[ ! $? -eq 0 ]]
then  
    podman build --tag='python:django' -f='./dockerfiles/dockerfile_django'
fi

echo -e "\nI will now create and provision the containers."

${SCRIPTS_ROOT}/scripts/create_all.sh
