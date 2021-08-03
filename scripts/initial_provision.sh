#!/bin/bash

source ${SCRIPTS_ROOT}/.proj

runuser --login ${USER_NAME} -c "podman image exists python:latest"
if [[ ! $? -eq 0 ]]
then
	runuser --login ${USER_NAME} -c "podman pull docker.io/library/python:latest &"
fi

runuser --login ${USER_NAME} -c "podman image exists elasticsearch:7.11.2"
if [[ ! $? -eq 0 ]]
then
	runuser --login ${USER_NAME} -c "podman pull docker.io/library/elasticsearch:7.11.2 &"
fi

runuser --login ${USER_NAME} -c "podman image exists mariadb:10.5"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/library/mariadb:10.5 &"
fi

runuser --login ${USER_NAME} -c "podman image exists redis:6.2.2-buster"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/library/redis:6.2.2-buster &"
fi

runuser --login ${USER_NAME} -c "podman image exists docker-clamav:latest"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/mkodockx/docker-clamav:latest &"
fi

runuser --login ${USER_NAME} -c "podman image exists duckdns:latest"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/linuxserver/duckdns:latest &"
fi

runuser --login ${USER_NAME} -c "podman image exists swag:1.14.0"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/linuxserver/swag:version-1.14.0 &"
fi

wait

if [[ ${DEBUG} == "TRUE" ]]
then
    runuser --login ${USER_NAME} -c "podman image exists \"python:${PROJECT_NAME}_debug\""
    if [[ ! $? -eq 0 ]]
    then
        mkdir -p /var/home/${USER_NAME}/django && cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/* /var/home/${USER_NAME}/django/
        chown -R ${USER_NAME}:${USER_NAME} /var/home/${USER_NAME}/django
        cp ${SCRIPTS_ROOT}/dockerfiles/dockerfile_django_dev /var/home/${USER_NAME}/dockerfile_django_dev
        cp ${SCRIPTS_ROOT}/dockerfiles/pip_requirements_dev /var/home/${USER_NAME}/pip_requirements_dev
        runuser --login ${USER_NAME} -c "podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --tag=\"python:${PROJECT_NAME}_debug\" -f='dockerfiles/dockerfile_django_dev'"
        rm /var/home/${USER_NAME}/dockerfile_django_dev /var/home/${USER_NAME}/pip_requirements_dev
        rm -r /var/home/${USER_NAME}/django/media
    fi
else
    runuser --login ${USER_NAME} -c "podman image exists \"python:${PROJECT_NAME}_prod\""
    if [[ ! $? -eq 0 ]]
    then
        mkdir -p /var/home/${USER_NAME}/django && cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/* /var/home/${USER_NAME}/django/
        chown -R ${USER_NAME}:${USER_NAME} /var/home/${USER_NAME}/django
        cp dockerfiles/pip_requirements_prod /var/home/${USER_NAME}/pip_requirements_prod
        cp dockerfiles/dockerfile_django_prod /var/home/${USER_NAME}/dockerfile_django_prod
        runuser --login ${USER_NAME} -c "podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --tag=\"python:${PROJECT_NAME}_prod\" -f='dockerfile_django_prod' ."
        rm /var/home/${USER_NAME}/dockerfile_django_prod /var/home/${USER_NAME}/pip_requirements_prod
        rm -r /var/home/${USER_NAME}/django/media
    fi
fi

function build_swag()
{
   rm ${SCRIPTS_ROOT}/.images
   cp dockerfiles/dockerfile_swag_prod /var/home/${USER_NAME}/dockerfile_swag_prod
   runuser --login ${USER_NAME} -c "podman build --tag='swag:artisan' -f='dockerfile_swag_prod' ."
   echo -e "[swag]" > ${SCRIPTS_ROOT}/.images
   echo -e "TL_DOMAIN=${EXTRA_DOMAINS}" >> ${SCRIPTS_ROOT}/.images
   echo -e "DUCK_DOMAIN=${DUCKDNS_SUBDOMAIN}" >> ${SCRIPTS_ROOT}/.images 
}

if [[ ${DEBUG} == "FALSE" ]]
then
    runuser --login ${USER_NAME} -c "podman image exists swag:artisan"
    if [[ ! $? -eq 0 ]]
    then
        if [[ -e ${SCRIPTS_ROOT}/.images ]]
        then
            source ${SCRIPTS_ROOT}/.images
            if [[ ${TL_DOMAIN} != ${EXTRA_DOMAINS} || ${DUCK_DOMAIN} != ${DUCKDNS_SUBDOMAIN} ]]
            then
                build_swag
            fi
        else
            build_swag
        fi
    fi
fi