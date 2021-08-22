#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${SCRIPTS_ROOT}/.proj

cp ${SCRIPTS_ROOT}/scripts/image_acq.sh /home/${USER_NAME}/image_acq.sh
cp ${SCRIPTS_ROOT}/.proj /home/${USER_NAME}/.proj
chown ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/image_acq.sh  /home/${USER_NAME}/.proj
chmod +x /home/${USER_NAME}/image_acq.sh
runuser --login ${USER_NAME} -c "SCRIPTS_ROOT=${SCRIPTS_ROOT} /home/${USER_NAME}/image_acq.sh"
wait $!
rm /home/${USER_NAME}/image_acq.sh /home/${USER_NAME}/.proj

function build_django()
{
  mkdir -p /home/${USER_NAME}/django && cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/* /home/${USER_NAME}/django/
  chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/django
  cp ${SCRIPTS_ROOT}/dockerfiles/${1} /home/${USER_NAME}/${1}
  cp ${SCRIPTS_ROOT}/dockerfiles/${2} /home/${USER_NAME}/${2}
  runuser --login ${USER_NAME} -c "podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --tag=\"python:${PROJECT_NAME}_debug\" -f=${1} ./"
  rm /home/${USER_NAME}/${1} /home/${USER_NAME}/${2}
  rm -r /home/${USER_NAME}/django
}

if [[ ${DEBUG} == "TRUE" ]]
then
    runuser --login ${USER_NAME} -c "podman image exists \"python:${PROJECT_NAME}_debug\""
    if [[ ! $? -eq 0 ]]
    then
        build_django dockerfile_django_dev pip_requirements_dev
        # mkdir -p /home/${USER_NAME}/django && cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/* /home/${USER_NAME}/django/
        # chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/django
        # cp ${SCRIPTS_ROOT}/dockerfiles/dockerfile_django_dev /home/${USER_NAME}/dockerfile_django_dev
        # cp ${SCRIPTS_ROOT}/dockerfiles/pip_requirements_dev /home/${USER_NAME}/pip_requirements_dev
        # runuser --login ${USER_NAME} -c "podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --tag=\"python:${PROJECT_NAME}_debug\" -f='dockerfile_django_dev' ./"
        # rm /home/${USER_NAME}/dockerfile_django_dev /home/${USER_NAME}/pip_requirements_dev
        # rm -r /home/${USER_NAME}/django
    fi
else
    runuser --login ${USER_NAME} -c "podman image exists \"python:${PROJECT_NAME}_prod\""
    if [[ ! $? -eq 0 ]]
    then
        # mkdir -p /home/${USER_NAME}/django && cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/* /home/${USER_NAME}/django/
        # chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/django
        # cp ${SCRIPTS_ROOT}/dockerfiles/dockerfile_django_prod /home/${USER_NAME}/dockerfile_django_prod
        # cp ${SCRIPTS_ROOT}/dockerfiles/pip_requirements_prod /home/${USER_NAME}/pip_requirements_prod
        # runuser --login ${USER_NAME} -c "podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --tag=\"python:${PROJECT_NAME}_prod\" -f='dockerfile_django_prod' ./"
        # rm /home/${USER_NAME}/dockerfile_django_prod /home/${USER_NAME}/pip_requirements_prod
        # rm -r /home/${USER_NAME}/django
        build_django dockerfile_django_prod pip_requirements_prod
    fi
fi

function build_swag()
{
   if [[ -e ${SCRIPTS_ROOT}/.images/swag ]]
   then
      rm ${SCRIPTS_ROOT}/.images/swag
   fi
   cp dockerfiles/dockerfile_swag /home/${USER_NAME}/dockerfile_swag
   cp dockerfiles/swag/default /home/${USER_NAME}/default
   cp dockerfiles/swag/nginx /home/${USER_NAME}/nginx
   runuser --login ${USER_NAME} -c "podman build --tag='swag:artisan' -f='dockerfile_swag' ."
   echo -e "TL_DOMAIN=${EXTRA_DOMAINS}" > ${SCRIPTS_ROOT}/.images/swag
   echo -e "DUCK_DOMAIN=${DUCKDNS_SUBDOMAIN}" >> ${SCRIPTS_ROOT}/.images/swag
   rm /home/${USER_NAME}/dockerfile_swag /home/${USER_NAME}/default /home/${USER_NAME}/nginx
}

if [[ ${DEBUG} == "FALSE" ]]
then
    runuser --login ${USER_NAME} -c "podman image exists swag:artisan"
    if [[ $? -eq 0 ]]
    then
        if [[ -e ${SCRIPTS_ROOT}/.images/swag ]]
        then
            source ${SCRIPTS_ROOT}/.images/swag
            if [[ ${TL_DOMAIN} != ${EXTRA_DOMAINS} || ${DUCK_DOMAIN} != ${DUCKDNS_SUBDOMAIN} ]]
            then
                build_swag
            fi
        fi
    else
        build_swag
    fi
fi

function build_maria()
{
   if [[ -e ${SCRIPTS_ROOT}/.images/maria ]]
   then
      rm ${SCRIPTS_ROOT}/.images/maria
   fi
   cp ${SCRIPTS_ROOT}/dockerfiles/dockerfile_maria /home/${USER_NAME}/dockerfile_maria
   cp ${SCRIPTS_ROOT}/dockerfiles/maria.sh /home/${USER_NAME}/maria.sh
   runuser --login ${USER_NAME} -c "podman build --tag='maria:artisan' -f='dockerfile_maria'"
   echo -e "DBNAME=${DB_NAME}" > ${SCRIPTS_ROOT}/.images/maria
   echo -e "DBUSER=${DB_USER}" >> ${SCRIPTS_ROOT}/.images/maria 
   echo -e "DBHOST=${DB_HOST}" >> ${SCRIPTS_ROOT}/.images/maria 
   rm /home/${USER_NAME}/dockerfile_maria /home/${USER_NAME}/maria.sh
}

runuser --login ${USER_NAME} -c "podman image exists maria:artisan"
if [[ $? -eq 0 ]]
then
    if [[ -e ${SCRIPTS_ROOT}/.images/maria ]]
    then
        source ${SCRIPTS_ROOT}/.images/maria
        if [[ ${DBNAME} != ${DB_NAME} || ${DBUSER} != ${DB_USER} || ${DBHOST} != ${DB_HOST} ]]
        then
            build_maria
        fi
     fi
else
    build_maria
fi
