#!/bin/bash

function build_maria()
{
   if [[ -e ${SCRIPTS_ROOT}/.images/maria ]]
   then
      rm ${SCRIPTS_ROOT}/.images/maria
   fi
   cp ${SCRIPTS_ROOT}/dockerfiles/dockerfile_maria /home/${USER_NAME}/dockerfile_maria
   cp ${SCRIPTS_ROOT}/dockerfiles/maria.sh /home/${USER_NAME}/maria.sh
   chown ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/dockerfile_maria /home/${USER_NAME}/maria.sh
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