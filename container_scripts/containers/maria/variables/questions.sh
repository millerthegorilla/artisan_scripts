#!/bin/bash

LOCAL_SETTINGS_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh

# DB_NAME
db_name=${project_name}_db
read -p "Your django database name [${db_name}] : " DB_NAME
DB_NAME=${DB_NAME:-${db_name}}

echo "DB_NAME=${DB_NAME}" >> ${LOCAL_SETTINGS_FILE}

# DB_USER
db_user=${db_name}_user
read -p "Your django database username [${db_user}]: " DB_USER
DB_USER=${DB_USER:-${db_user}}

echo "SDB_USER=${DB_USER}" >> ${LOCAL_SETTINGS_FILE}

# DB_PASSWORD
DB_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

echo "DB_PASSWORD=${DB_PASSWORD}" >> ${LOCAL_SETTINGS_FILE}

# DB_HOST
db_host=127.0.0.1
read -p "Your django database host address [${db_host}] : " DB_HOST
DB_HOST=${DB_HOST:-${db_host}}

echo "DB_HOST=${DB_HOST}" >> ${LOCAL_SETTINGS_FILE}

# DB_VOL
db_vol_name="db_vol"
read -p "Host db volume name [ ${db_vol_name} ] : " DB_VOL
DB_VOL=${DB_VOL:-${db_vol_name}}

echo "DB_VOL=${DB_VOL}" >> ${LOCAL_SETTINGS_FILE}

# MARIADB_ROOT_PASSWORD
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/make_secret.sh

make_secret MARIADB_ROOT_PASSWORD

# TODO check if DB_PASSWORD exists before deleting it.
runuser --login ${USER_NAME} -c "podman secret rm DB_PASSWORD"
echo -n $DB_PASSWORD | runuser --login "${USER_NAME}" -c "podman secret create \"DB_PASSWORD\" -"

# MARIA_CONT_NAME
MARIA_CONT_NAME="maria_cont"

echo "MARIA_CONT_NAME=${MARIA_CONT_NAME}" >> ${LOCAL_SETTINGS_FILE}

# MARIA_IMAGE
MARIA_IMAGE=$(get_tag $BASH_SOURCE)

echo "MARIA_IMAGE=${MARIA_IMAGE}" >> ${LOCAL_SETTINGS_FILE}
