#!/bin/bash

podman run -dit --name ${MARIA_CONT_NAME} --pod ${POD_NAME} -e MYSQL_ALLOW_EMPTY_PASSWORD=True ${MARIA_IMAGE} 

echo -e "\nConfiguring Database - please enter database root password.  The database root password is not stored anywhere on the file system so take a careful note of what it is and make sure it is a secure password - chars and numbers with a length of greater than 30 if possible.  Try the bash command: \n < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;\n"
 
read -p "Db root password:" DB_ROOT_PASSWORD

echo -e "\nYou will need to enter the root password again, as I am about to run the script mysql_secure_installation.\n\nThe database currently has no root password set, so press enter to the first question, and disable socket authentication for the second question.\n\nMake certain that you then enter the new database root password to secure the database for the third question.\n\nThen press enter through the rest of the questions to accept the defaults\n\n"

sleep 15;
podman exec -it ${MARIA_CONT_NAME} bash -c "mysql_secure_installation"

echo -e "\n\n"

podman exec -e DB_NAME=${DB_NAME} -e DB_USER=${DB_USER} -e DB_PASSWORD=${DB_PASSWORD} -e DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD} -d ${MARIA_CONT_NAME} bash -c 'mysql --defaults-file="/defaults.cnf" -uroot -p${DB_ROOT_PASSWORD} -e "CREATE DATABASE ${DB_NAME} CHARSET utf8; grant all privileges on ${DB_NAME}.* TO ${DB_USER}@127.0.0.1 identified by \"${DB_PASSWORD}\";"'
