source ${PROJECT_SETTINGS}

function build_django()
{
  echo -e "\n*** Building custom django image.  This can take a *long* time... ***\n"
  mkdir -p /home/${USER_NAME}/django && cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/* /home/${USER_NAME}/django/
  chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/django
  cp ${SCRIPTS_ROOT}/dockerfiles/${1} /home/${USER_NAME}/${1}
  cp ${SCRIPTS_ROOT}/dockerfiles/${2} /home/${USER_NAME}/${2}
  echo "media dir is " ${DJANGO_HOST_MEDIA_VOL}
  runuser --login ${USER_NAME} -c "podman build --build-arg=PROJECT_NAME=${PROJECT_NAME} --build-arg=STATIC_DIR=${DJANGO_HOST_STATIC_VOL} --build-arg=MEDIA_DIR=${DJANGO_HOST_MEDIA_VOL} --tag=\"${CUSTOM_TAG}\" -f=${1} ./"
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