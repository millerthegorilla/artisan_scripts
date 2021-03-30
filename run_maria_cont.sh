!#/bin/bash

podman run -dit  --name ${MARIA_CONT_NAME} --pod ${POD_NAME} -e MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD} ${MARIA_IMAGE}
podman exec -d ${MARIA_CONT_NAME} bash -c "mysql -e "CREATE DATABASE 
