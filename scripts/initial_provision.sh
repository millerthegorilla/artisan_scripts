#!/bin/bash

source ${SCRIPTS_ROOT}/.proj

chown ${USER_NAME}:${USER_NAME} ${SCRIPTS_ROOT}/scripts/image_ack.sh
runuser --login ${USER_NAME} -c "SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/image_ack.sh"
chown root:root ${SCRIPTS_ROOT}/scripts/image_ack.sh

if [[ ${DEBUG} == "TRUE" ]]
then
    runuser --login ${USER_NAME} -c "podman image exists \"python:${PROJECT_NAME}_debug\""
    if [[ ! $? -eq 0 ]]
    then
        mkdir -p /home/${USER_NAME}/django && cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/* /home/${USER_NAME}/django/
        chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/django
        cp ${SCRIPTS_ROOT}/dockerfiles/dockerfile_django_dev /home/${USER_NAME}/dockerfile_django_dev
        cp ${SCRIPTS_ROOT}/dockerfiles/pip_requirements_dev /home/${USER_NAME}/pip_requirements_dev
        runuser --login ${USER_NAME} -c "podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --tag=\"python:${PROJECT_NAME}_debug\" -f='dockerfiles/dockerfile_django_dev'"
        rm /home/${USER_NAME}/dockerfile_django_dev /home/${USER_NAME}/pip_requirements_dev
        rm -r /home/${USER_NAME}/django
    fi
else
    runuser --login ${USER_NAME} -c "podman image exists \"python:${PROJECT_NAME}_prod\""
    if [[ ! $? -eq 0 ]]
    then
        mkdir -p /home/${USER_NAME}/django && cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/* /home/${USER_NAME}/django/
        chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/django
        cp dockerfiles/pip_requirements_prod /home/${USER_NAME}/pip_requirements_prod
        cp dockerfiles/dockerfile_django_prod /home/${USER_NAME}/dockerfile_django_prod
        runuser --login ${USER_NAME} -c "podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --tag=\"python:${PROJECT_NAME}_prod\" -f='dockerfile_django_prod' ."
        rm /home/${USER_NAME}/dockerfile_django_prod /home/${USER_NAME}/pip_requirements_prod
        rm -r /home/${USER_NAME}/django
    fi
fi

function build_swag()
{
   rm ${SCRIPTS_ROOT}/.images
   cp dockerfiles/dockerfile_swag_prod /home/${USER_NAME}/dockerfile_swag_prod
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