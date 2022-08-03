#!/bin/bash

mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY \"${MARIADB_ROOT_PASSWORD}\"; flush privileges;"

mysql -uroot  -p${MARIADB_ROOT_PASSWORD} -e "delete from mysql.global_priv where user='root' and host='%'; flush privileges;"

mysql -uroot -p${MARIADB_ROOT_PASSWORD} -e "CREATE DATABASE ${DB_NAME} CHARSET utf8;"
    
mysql -uroot -p${MARIADB_ROOT_PASSWORD} -e "grant CREATE, ALTER, INDEX, SELECT, UPDATE, INSERT, DELETE, DROP, LOCK TABLES on ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} identified by '${DB_PASSWORD}'; flush privileges;"

rm -f /tmp/.finished
