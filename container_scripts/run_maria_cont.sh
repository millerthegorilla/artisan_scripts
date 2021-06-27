#!/bin/bash

podman run -dit -e MARIADB_ROOT_PASSWORD='davebob' --name ${MARIA_CONT_NAME} --pod ${POD_NAME} ${MARIA_IMAGE}
 
read -p "Enter your MYSQL_ROOT_PASSWORD : " mysql_root_password
podman exec -e DB_HOST=${MARIADB_HOST} -e MYSQL_ROOT_PASSWORD=${mysql_root_password} -it ${MARIA_CONT_NAME} bash -c "mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'CREATE DATABASE ${DB_NAME} CHARSET utf8; grant all privileges on ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} identified by ${DB_PASSWORD};'"
unset mysql_root_password
# mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'CREATE DATABASE ${DB_NAME} CHARSET utf8; grant all privileges on ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} identified by \'${DB_PASSWORD}\';

#podman stop ${MARIA_CONT_NAME}
#podman start ${MARIA_CONT_NAME}