!#/bin/bash

podman run -dit  --name ${MARIA_CONT_NAME} --pod ${POD_NAME} -e MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD} ${MARIA_IMAGE}
podman exec -d ${MARIA_CONT_NAME} bash -c 'mysql -e "CREATE DATABASE ${DB_NAME} CHARACTER SET utf8;grant all privileges on ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' identified by '${DB_PASSWORD};"'
