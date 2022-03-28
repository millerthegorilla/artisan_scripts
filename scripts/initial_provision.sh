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
  echo -e "\n*** Building custom django image.  This can take a *long* time... ***\n"
  mkdir -p /home/${USER_NAME}/django && cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/* /home/${USER_NAME}/django/
  chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/django
  cp ${SCRIPTS_ROOT}/dockerfiles/${1} /home/${USER_NAME}/${1}
  cp ${SCRIPTS_ROOT}/dockerfiles/${2} /home/${USER_NAME}/${2}
  runuser --login ${USER_NAME} -c "podman build --build-arg PROJECT_NAME=${PROJECT_NAME} --build-arg STATIC_DIR=${DJANGO_HOST_STATIC_VOL} --build-arg MEDIA_DIR=${DJANGO_HOST_MEDIA_VOL} --tag=\"python:${PROJECT_NAME}_${3}\" -f=${1} ./"
  rm /home/${USER_NAME}/${1} /home/${USER_NAME}/${2}
  rm -r /home/${USER_NAME}/django
}

if [[ ${DEBUG} == "TRUE" ]]
then
    runuser --login ${USER_NAME} -c "podman image exists \"python:${PROJECT_NAME}_debug\""
    if [[ ! $? -eq 0 ]]
    then
        build_django dockerfile_django_dev pip_requirements_dev debug
    fi
else
    runuser --login ${USER_NAME} -c "podman image exists \"python:${PROJECT_NAME}_prod\""
    if [[ ! $? -eq 0 ]]
    then
        build_django dockerfile_django_prod pip_requirements_prod prod
    fi
fi

function build_swag()
{
   if [[ -e ${SCRIPTS_ROOT}/.images/swag ]]
   then
      rm ${SCRIPTS_ROOT}/.images/swag
   fi
   cp ${SCRIPTS_ROOT}/dockerfiles/dockerfile_swag /home/${USER_NAME}/dockerfile_swag
   cp ${SCRIPTS_ROOT}/dockerfiles/swag/default /home/${USER_NAME}/default
   cp ${SCRIPTS_ROOT}/dockerfiles/swag/nginx /home/${USER_NAME}/nginx
   cp ${SCRIPTS_ROOT}/dockerfiles/swag/50-config /home/${USER_NAME}/50-config
   runuser --login ${USER_NAME} -c "podman build --tag='swag:artisan' -f='dockerfile_swag' ."
   echo -e "TL_DOMAIN=${EXTRA_DOMAINS}" > ${SCRIPTS_ROOT}/.images/swag
   echo -e "DUCK_DOMAIN=${DUCKDNS_SUBDOMAIN}" >> ${SCRIPTS_ROOT}/.images/swag
   rm /home/${USER_NAME}/dockerfile_swag /home/${USER_NAME}/default /home/${USER_NAME}/nginx /home/${USER_NAME}/50-config
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
        else
          build_swag
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
   runuser --login ${USER_NAME} -c "podman build --tag='maria:artisan_${1}' -f='dockerfile_maria'"
   echo -e "DBNAME=${DB_NAME}" > ${SCRIPTS_ROOT}/.images/maria
   echo -e "DBUSER=${DB_USER}" >> ${SCRIPTS_ROOT}/.images/maria 
   echo -e "DBHOST=${DB_HOST}" >> ${SCRIPTS_ROOT}/.images/maria 
   rm /home/${USER_NAME}/dockerfile_maria /home/${USER_NAME}/maria.sh
}

if [[ ${DEBUG} == "TRUE" ]]
then
    postfix="dev"
else
    postfix="prod"
fi

runuser --login ${USER_NAME} -c "podman image exists maria:artisan_${postfix}"

if [[ $? -eq 0 ]]
then
    if [[ -e ${SCRIPTS_ROOT}/.images/maria ]]
    then
        source ${SCRIPTS_ROOT}/.images/maria
        if [[ ${DBNAME} != ${DB_NAME} || ${DBUSER} != ${DB_USER} || ${DBHOST} != ${DB_HOST} ]]
        then
            build_maria ${postfix}
        fi
        # maria image doesn't need to be built
    else
        build_maria ${postfix}
    fi
else
    build_maria ${postfix}
fi
