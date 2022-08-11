#!/bin/bash

source ${PROJECT_SETTINGS}

if [[ -z "${PROJECT_NAME}" ]]
then
read -p "Enter your artisan_scripts project name : " PROJECT_NAME
fi
if [[ -z "${DEBUG}" ]]
then
echo -e "\nIs this development ie debug? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) DEBUG="TRUE"; break;;
        No ) DEBUG="FALSE"; break;;
    esac
done
fi
if [[ -n "${CURRENT_SETTINGS}" ]]
then
  echo -e "\nCurrent Settings is ${CURRENT_SETTINGS}"
fi
if [[ ${DEBUG} == "TRUE" ]]   ## TODO function 
then   # TODO function for below
  echo "Please select the settings file from the list"

  files=$(ls ${CONTAINER_SCRIPTS_ROOT}/settings/development)
  i=1

  for j in $files
  do
  echo "$i.$j"
  file[i]=$j
  i=$(( i + 1 ))
  done

  echo "Enter number"
  read input
  cp ${CONTAINER_SCRIPTS_ROOT}/settings/development/${file[${input}]} ${CONTAINER_SCRIPTS_ROOT}/settings/settings.py 
else
  echo "Please select the settings file from the list"

  files=$(ls ${CONTAINER_SCRIPTS_ROOT}/settings/production)
  i=1

  for j in $files
  do
  echo "$i.$j"
  file[i]=$j
  i=$(( i + 1 ))
  done
  echo "Enter number"
  read input
  cp ${CONTAINER_SCRIPTS_ROOT}/settings/production/${file[${input}]} ${CONTAINER_SCRIPTS_ROOT}/settings/settings.py
fi
sed -i '/CURRENT_SETTINGS/d' ${CURRENT_PROJECT_PATH}/PROJECT_SETTINGS
echo "CURRENT_SETTINGS="${file[${input}]} >> ${CURRENT_PROJECT_PATH}/PROJECT_SETTINGS
cp ${CONTAINER_SCRIPTS_ROOT}/settings/settings.py /etc/opt/${PROJECT_NAME}/settings
runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan /etc/opt/${PROJECT_NAME}/settings/settings.py\""
exit $?