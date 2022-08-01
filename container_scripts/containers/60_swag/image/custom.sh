#!/bin/bash

source ${PROJECT_SETTINGS}

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh
custom_tag=$(get_tag ${CURRENT_DIR})

CURRENT_VARS="${CURRENT_DIR}/current_vars"

function build_swag()
{
   if [[ -e ${CURRENT_VARS} ]]
   then
      rm ${CURRENT_VARS}
   fi
   cp ${CURRENT_DIR}/dockerfile/dockerfile /home/${USER_NAME}/dockerfile
   cp ${CURRENT_DIR}/dockerfile/swag/default /home/${USER_NAME}/default
   cp ${CURRENT_DIR}/dockerfile/swag/nginx /home/${USER_NAME}/nginx
   runuser --login ${USER_NAME} -c "podman build --tag=${custom_tag} -f='dockerfile' ."
   echo -e "TL_DOMAIN=${EXTRA_DOMAINS}" > ${CURRENT_VARS}
   echo -e "DUCK_DOMAIN=${DUCKDNS_DOMAIN}" >> ${CURRENT_VARS}
   rm /home/${USER_NAME}/dockerfile /home/${USER_NAME}/default /home/${USER_NAME}/nginx /home/${USER_NAME}/50-config
}

if [[ ${DEBUG} == "FALSE" ]]
then
    runuser --login ${USER_NAME} -c "podman image exists ${custom_tag}"
    if [[ $? -eq 0 ]]
    then
        if [[ -e ${CURRENT_VARS} ]]
        then
            source ${CURRENT_VARS}
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