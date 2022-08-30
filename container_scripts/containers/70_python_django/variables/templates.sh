#!/bin/bash

set -a
source ${PROJECT_SETTINGS}
set +a

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

if [[ ${DEBUG} == "TRUE" ]]
then
	cat ${CURRENT_DIR}/templates/dockerfile/dockerfile_dev | envsubst '$DOCKERFILE_APP_NAMES' > ${CURRENT_DIR}/../image/dockerfile/dockerfile_dev
else
	set -a
	    NUM_OF_WORKERS=$(($(nproc --all) * 2 + 1))
	set +a
	cat ${CURRENT_DIR}/templates/gunicorn/gunicorn.conf.py | envsubst > ${CONTAINER_SCRIPTS_ROOT}/settings/gunicorn.conf.py
    cat ${CURRENT_DIR}/templates/gunicorn/init | envsubst > ${CURRENT_DIR}/../image/dockerfile/django/init
fi

cat ${CURRENT_DIR}/templates/env/settings_env | envsubst > ${CONTAINER_SCRIPTS_ROOT}/settings/settings_env

cat ${CURRENT_DIR}/templates/django/manage.py | envsubst > ${CODE_PATH}/manage.py
chown ${USER_NAME}:${USER_NAME} ${CODE_PATH}/manage.py

cat ${CURRENT_DIR}/templates/django/wsgi.py | envsubst > ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py
chown ${USER_NAME}:${USER_NAME} ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py