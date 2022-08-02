#!/bin/bash

echo debug maria templates maria_dev.sh
echo MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD}
echo DB_PASSWORD=${DB_PASSWORD}
echo DB_NAME=${DB_NAME}
echo DB_USER=${DB_USER}
echo DB_HOST=${DB_HOST}

if ! mariadb-show -uroot -p${MARIADB_ROOT_PASSWORD} | grep ${DB_NAME} &>/dev/null;
then
    mysql -uroot  -p${MARIADB_ROOT_PASSWORD} -h'localhost' -e "delete from mysql.global_priv where user='root' and host='%'; flush privileges;"

    mysql -uroot -p${MARIADB_ROOT_PASSWORD} -e "CREATE DATABASE ${DB_NAME} CHARSET utf8;"
    
    mysql -uroot -p${MARIADB_ROOT_PASSWORD} -e "grant CREATE, ALTER, INDEX, SELECT, UPDATE, INSERT, DELETE, DROP, LOCK TABLES on ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} identified by '${DB_PASSWORD}'; flush privileges;"
fi

unset MARIADB_ROOT_PASSWORD
unset DB_PASSWORD
unset DB_NAME
unset DB_USER
unset DB_HOST

rm -f /tmp/.finished
