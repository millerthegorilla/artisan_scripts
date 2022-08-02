#!/bin/bash

if [[ $(runuser --login artisan_sysd -P -c "podman exec -it mariadb_cont bash -c \"mariadb-show -uroot -p${MARIADB_ROOT_PASSWORD} ${db_name}\"" > /dev/null 2>&1; echo $?) -eq 1 ]]
then
    mysql -uroot  -p${MARIADB_ROOT_PASSWORD} -h'localhost' -e "delete from mysql.global_priv where user='root' and host='%'; flush privileges;"

    mysql -uroot -p${MARIADB_ROOT_PASSWORD} -e "CREATE DATABASE ${db_name} CHARSET utf8;"
    
    mysql -uroot -p${MARIADB_ROOT_PASSWORD} -e "grant CREATE, ALTER, INDEX, SELECT, UPDATE, INSERT, DELETE, DROP, LOCK TABLES on ${db_name}.* TO ${db_user}@${db_host} identified by '${DB_PASSWORD}'; flush privileges;"
fi

rm -f /tmp/.finished
