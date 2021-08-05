#!/bin/bash

echo -e "run_maria_cont.sh"

source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.proj

runuser --login ${USER_NAME} -P -c "podman run -dit --secret=MARIADB_ROOT_PASSWORD,type=env --name \"${MARIA_CONT_NAME}\" -v dbvol:/var/lib/mysql:Z --pod \"${POD_NAME}\" ${MARIA_IMAGE} &"

echo "Waiting for Database container to be ready"
read -p "Enter your MYSQL_ROOT_PASSWORD : " mysql_root_password
until runuser --login ${USER_NAME} -P -c "podman exec -e ROOT_PASSWORD=\"${mysql_root_password}\" -it \"${MARIA_CONT_NAME}\" bash -c \"mysql -uroot  -p\"\${ROOT_PASSWORD}\" -h'localhost' --protocol=tcp -e \"delete from mysql.global_priv where user='root' and host='%'; flush privileges;\" > /dev/null 2>\&"
do
	echo -n "."
done
until runuser --login ${USER_NAME} -P -c "podman exec -e ROOT_PASSWORD=\"${mysql_root_password}\" -e DB_NAME=\"${DB_NAME}\" -e DB_USER=\"${DB_USER}\" -e DB_HOST=\"${DB_HOST}\" -e DB_PASSWORD=\"${DB_PASSWORD}\" -it \"${MARIA_CONT_NAME}\" bash -c \"mysql -uroot -h'localhost' -p\"\"\${ROOT_PASSWORD}\"\" -e \"\"CREATE DATABASE ${DB_NAME} CHARSET utf8; grant all privileges on ${DB_NAME}.* TO '${DB_USER}'@'${DB_HOST}' identified by '${DB_PASSWORD}';\"\""
do
	if [[ $(runuser --login ${USER_NAME} -c "podman inspect ${MARIA_CONT_NAME} |grep running > /dev/null 2>&1; echo $?)" -eq 1 ]]
	then
		runuser --login ${USER_NAME} -c "podman start ${MARIA_CONT_NAME}"
	fi
	echo -n "."
done
unset mysql_root_password
