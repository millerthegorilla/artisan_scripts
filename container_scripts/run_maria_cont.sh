#!/bin/bash

podman run -dit --secret=MARIADB_ROOT_PASSWORD,type=env --name ${MARIA_CONT_NAME} --pod ${POD_NAME} ${MARIA_IMAGE}

echo -e "Waiting for mysql to be ready.."
until podman exec -it ${MARIA_CONT_NAME} bash -c "ls /run/mysqld/mysqld.sock" &>/dev/null;
do
  echo -n "."
done

read -p "Enter your MYSQL_ROOT_PASSWORD : " mysql_root_password
podman exec -e MYSQL_ROOT_PASSWORD=${mysql_root_password} -e DB_NAME=${DB_NAME} -e DB_USER=${DB_USER} -e DB_HOST=${DB_HOST} -e DB_PASSWORD=${DB_PASSWORD} -it ${MARIA_CONT_NAME} bash -c "mysql -uroot -p\${MYSQL_ROOT_PASSWORD} -e \"CREATE DATABASE \${DB_NAME} CHARSET utf8; grant all privileges on \${DB_NAME}.* TO \${DB_USER}@\${DB_HOST} identified by '$\{DB_PASSWORD}';\""
unset mysql_root_password
# mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'CREATE DATABASE ${DB_NAME} CHARSET utf8; grant all privileges on ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} identified by \'${DB_PASSWORD}\';

#podman stop ${MARIA_CONT_NAME}
#podman start ${MARIA_CONT_NAME}