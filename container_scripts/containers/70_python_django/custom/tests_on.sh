#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

if [[ -z ${MARIA_CONT_NAME} ]]
then
  echo "No database container is found!";
  exit 1;
fi
read -p "Database root password? : " ROOT_PWD
runuser --login ${USER_NAME} -P -c "podman exec -it ${MARIA_CONT_NAME} bash -c \"echo 'grant all on *.* to ${DB_USER}@${DB_HOST}; flush privileges;' | mysql -uroot -p${ROOT_PWD}\""