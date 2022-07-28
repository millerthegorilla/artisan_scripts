#!/bin/bash

source ${PROJECT_SETTINGS}
source "$(dirname ${BASH_SOURCE})/source.sh"

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
   runuser --login ${USER_NAME} -c "podman build --tag=${CUSTOM_TAG} -f='dockerfile_swag' ."
   echo -e "TL_DOMAIN=${EXTRA_DOMAINS}" > ${SCRIPTS_ROOT}/.images/swag
   echo -e "DUCK_DOMAIN=${DUCKDNS_DOMAIN}" >> ${SCRIPTS_ROOT}/.images/swag
   rm /home/${USER_NAME}/dockerfile_swag /home/${USER_NAME}/default /home/${USER_NAME}/nginx /home/${USER_NAME}/50-config
}

if [[ ${DEBUG} == "FALSE" ]]
then
    runuser --login ${USER_NAME} -c "podman image exists ${CUSTOM_TAG}"
    if [[ $? -eq 0 ]]
    then
        if [[ -e ${SCRIPTS_ROOT}/.images/swag ]]
        then
            source ${SCRIPTS_ROOT}/.images/swag
            if [[ ${TL_DOMAIN} != ${EXTRA_DOMAINS} || ${DUCK_DOMAIN} != ${DUCKDNS_DOMAIN} ]]
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