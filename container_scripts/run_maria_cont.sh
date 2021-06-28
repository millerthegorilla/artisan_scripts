#!/bin/bash

read -p "Enter your MYSQL_ROOT_PASSWORD : " mysql_root_password
podman run -dit -e MARIADB_ROOT_PASSWORD='davebob' -e MARIADB_ROOT_HOST='127.0.0.1' --name ${MARIA_CONT_NAME} --pod ${POD_NAME} ${MARIA_IMAGE} --old-passwords=0
podman stop ${MARIA_CONT_NAME}
podman start ${MARIA_CONT_NAME}
echo -e "Waiting for mysql to be ready.."
until podman exec -it ${MARIA_CONT_NAME} bash -c "ls /run/mysqld/mysqld.sock" &>/dev/null;
do
  echo -n "."
done
podman exec -e ROOT_PASSWORD='davebob' -e DB_NAME=${DB_NAME} -e DB_USER=${DB_USER} -e DB_HOST=${DB_HOST} -e DB_PASSWORD=${DB_PASSWORD} -it ${MARIA_CONT_NAME} bash -c "mysql -uroot -p\${ROOT_PASSWORD} -h127.0.0.1 -e \"CREATE DATABASE \${DB_NAME} CHARSET utf8; grant all privileges on \${DB_NAME}.* TO \${DB_USER}@\${DB_HOST} identified by '$\{DB_PASSWORD}';\""
unset mysql_root_password
# mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'CREATE DATABASE ${DB_NAME} CHARSET utf8; grant all privileges on ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} identified by \'${DB_PASSWORD}\';

#podman stop ${MARIA_CONT_NAME}
#podman start ${MARIA_CONT_NAME}