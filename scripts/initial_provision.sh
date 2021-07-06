#!/bin/bash

echo PROJECT_NAME=${PROJECT_NAME} > .proj
echo USER=${USER} >> .proj
echo USER_DIR=${USER_DIR} >> .proj
echo SCRIPTS_ROOT=${SCRIPTS_ROOT} >> .proj
echo CODE_PATH=${CODE_PATH} >> .proj

echo -e "\nI will first create the directories.\n"
echo debug is ${DEBUG}

exists=$(type -t super_access)
if [[ ${exists} != "function " ]]
then
    source ${SCRIPTS_ROOT}/scripts/super_access.sh
fi

SUNAME=${SUNAME} super_access "SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/create_directories.sh" 

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
podman image exists mariadb:10.5
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/library/mariadb:10.5 &
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

if [[ ${DEBUG} == "TRUE" ]]
then
    podman image exists python:artisan_debug
    if [[ ! $? -eq 0 ]]
    then
        podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --tag='python:artisan_debug' -f='dockerfiles/dockerfile_django_dev'
    fi
else
    podman image exists python:artisan_prod
    if [[ ! $? -eq 0 ]]
    then
        cp -ar ${CODE_PATH}/media ${SCRIPTS_ROOT}/dockerfiles/django
        cp ${SCRIPTS_ROOT}/settings/supervisor_gunicorn ${SCRIPTS_ROOT}/dockerfiles/django/supervisor_gunicorn
        podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --build-arg=SCRIPTS_ROOT=${SCRIPTS_ROOT} --build-arg=CODE_PATH=${CODE_PATH} --tag='python:artisan_prod' -f='dockerfiles/dockerfile_django_prod'
    fi
fi

# podman image exists maria:artisan
# if [[ ! $? -eq 0 ]]
# then
#     if [[ ${DEBUG} == "TRUE" ]]
#     then  
#         podman build --tag='maria:artisan' -f='dockerfiles/dockerfile_maria_dev'
#     else
#         podman build --tag='maria:artisan' -f='dockerfiles/dockerfile_maria_prod'
#     fi
# fi

if [[ ${DEBUG} == "FALSE" ]]
then
    podman image exists swag:artisan
    if [[ ! $? -eq 0 ]]
    then
        podman build --build-arg=SCRIPTS_ROOT=${SCRIPTS_ROOT} --tag='swag:artisan' -f='dockerfiles/dockerfile_swag_prod'
    fi
fi

echo -e "\nI will now create and provision the containers."

${SCRIPTS_ROOT}/scripts/create_all.sh
