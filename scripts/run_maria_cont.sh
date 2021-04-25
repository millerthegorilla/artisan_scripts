#!/bin/bash

podman run -dit --name ${MARIA_CONT_NAME} --pod ${POD_NAME} -e MYSQL_ALLOW_EMPTY_PASSWORD="True" ${MARIA_IMAGE} 

sleep 2;

echo -e "\nupdating database defaults...\n"

podman cp ${SCRIPTS_ROOT}/templates/maria ${MARIA_CONT_NAME}:/maria.sh

# podman stop ${MARIA_CONT_NAME}

# podman start ${MARIA_CONT_NAME}

echo -e "\nYou will need to have the new database root password handy.\n\nThe database root password is not stored anywhere on the file system so take a careful note of what it is and make sure it is a secure password - chars and numbers with a length of greater than 30 if possible.  Try the bash command: \n\n < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;\n\nI am about to run the script mysql_secure_installation.\n\nThe database currently has no root password set, so press enter to the first question, and disable socket authentication for the second question.\n\nMake certain that you then enter the new database root password to secure the database for the third question.\n\nThen press enter through the rest of the questions to accept the defaults.\n\n"

sleep 8;
while read -t 0.01; do :; done

echo -e "Waiting for mysql to be ready.."
until podman exec -it ${MARIA_CONT_NAME} bash -c "ls /run/mysqld/mysqld.sock" &>/dev/null;
do
  echo -n "."
done

podman exec -it ${MARIA_CONT_NAME} bash -c "mysql_secure_installation"

echo -e "\n\n"

echo -e "\nSo I'm going to configure the database for your webapp - please enter the database root password."

read -p "Db root password:" DB_ROOT_PASSWORD

podman exec -e DB_NAME=${DB_NAME} -e DB_USER=${DB_USER} -e DB_HOST=${DB_HOST} -e DB_PASSWORD=${DB_PASSWORD} -e DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD} -it ${MARIA_CONT_NAME} bash -c "sh /maria.sh"

podman stop ${MARIA_CONT_NAME}
podman start ${MARIA_CONT_NAME}
