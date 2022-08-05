#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh
custom_tag=$(get_tag ${CURRENT_DIR})

function build_django()
{
  echo -e "\n*** Building custom django image.  This can take a *long* time... ***\n"
  mkdir -p /home/${USER_NAME}/django && cp -ar ${CURRENT_DIR}/dockerfile/django/* /home/${USER_NAME}/django/
  cp ${CURRENT_DIR}/dockerfile/${1} /home/${USER_NAME}/django/${1}
  cp ${CURRENT_DIR}/dockerfile/${2} /home/${USER_NAME}/django/${2}
  chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/django
  runuser --login ${USER_NAME} -c "podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --build-arg=STATIC_DIR=${DJANGO_HOST_STATIC_VOL} --build-arg=MEDIA_DIR=${DJANGO_HOST_MEDIA_VOL} --tag=\"${custom_tag}\" -f=/home/${USER_NAME}/django/${1} /home/dev/django/"
  rm /home/${USER_NAME}/django/${1} /home/${USER_NAME}/django/${2}
  rm -r /home/${USER_NAME}/django
}

if [[ ${DEBUG} == "TRUE" ]]
then
    runuser --login ${USER_NAME} -c "podman image exists \"${custom_tag}\""
    if [[ ! $? -eq 0 ]]
    then
        build_django dockerfile_dev pip_requirements_dev debug
    fi
else
    runuser --login ${USER_NAME} -c "podman image exists \"${custom_tag}\""
    if [[ ! $? -eq 0 ]]
    then
        build_django dockerfile_prod pip_requirements_prod prod
    fi
fi
