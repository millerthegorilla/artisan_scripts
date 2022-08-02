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
runuser --login ${USER_NAME} -P -c "podman exec -it ${MARIA_CONT_NAME} bash -c  \"echo 'revoke all privileges, grant option from ${DB_USER}@${DB_HOST}; flush privileges;' | mysql -uroot -p${ROOT_PWD}\""
if [[ ${DEBUG} == "TRUE" ]]
then
  runuser --login dev -P -c "podman exec -it ${MARIA_CONT_NAME} bash -c \"echo 'GRANT DROP, CREATE, ALTER, INDEX, SELECT, UPDATE, INSERT, DELETE, LOCK TABLES ON ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} IDENTIFIED BY \\\"${DB_PASSWORD}\\\"; flush privileges;' | mysql -uroot -p${ROOT_PWD}\""
else
  runuser --login dev -P -c "podman exec -it ${MARIA_CONT_NAME} bash -c \"echo 'GRANT CREATE, ALTER, INDEX, SELECT, UPDATE, INSERT, DELETE ON ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} IDENTIFIED BY \\\"${DB_PASSWORD}\\\"; flush privileges;' | mysql -uroot -p${ROOT_PWD}\""
fi