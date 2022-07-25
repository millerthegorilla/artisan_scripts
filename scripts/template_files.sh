#!/bin/bash

source .proj

cat ${SCRIPTS_ROOT}/templates/dockerfiles/dockerfile_django_dev | envsubst '$dockerfile_app_names' > ${SCRIPTS_ROOT}/dockerfiles/dockerfile_django_dev
cat ${SCRIPTS_ROOT}/templates/env_files/scripts_env | envsubst > ${SCRIPTS_ROOT}/.env
cat ${SCRIPTS_ROOT}/templates/env_files/settings_env | envsubst > ${SCRIPTS_ROOT}/settings/settings_env
cat ${SCRIPTS_ROOT}/templates/settings/archive | envsubst > ${SCRIPTS_ROOT}/.archive
cat ${SCRIPTS_ROOT}/templates/django/manage.py | envsubst > ${CODE_PATH}/manage.py
chown ${USER_NAME}:${USER_NAME} ${CODE_PATH}/manage.py
cat ${SCRIPTS_ROOT}/templates/django/wsgi.py | envsubst > ${CODE_PATH}/${django_project_name}/wsgi.py
chown ${USER_NAME}:${USER_NAME} ${CODE_PATH}/${django_project_name}/wsgi.py
cat ${SCRIPTS_ROOT}/templates/gunicorn/init | envsubst > ${SCRIPTS_ROOT}/dockerfiles/django/init
if [[ ${DEBUG} == "TRUE" ]]
then
    cat ${SCRIPTS_ROOT}/templates/maria/maria_dev.sh | envsubst '$db_user:$db_host:$db_name' > ${SCRIPTS_ROOT}/dockerfiles/maria.sh
 else
    cat ${SCRIPTS_ROOT}/templates/maria/maria_prod.sh | envsubst '$db_user:$db_host:$db_name' > ${SCRIPTS_ROOT}/dockerfiles/maria.sh
fi

if [[ ${DEBUG} == "FALSE" ]]
then
    set -a
        NUM_OF_WORKERS=$(($(nproc --all) * 2 + 1))
    set +a
    cat ${SCRIPTS_ROOT}/templates/gunicorn/gunicorn.conf.py | envsubst > ${SCRIPTS_ROOT}/settings/gunicorn.conf.py
    if [[ ${tldomain} == "TRUE" ]]
    then
        cat ${SCRIPTS_ROOT}/templates/swag/default_tld | envsubst '$tl_domain:$duckdns_domain' > ${SCRIPTS_ROOT}/dockerfiles/swag/default
    else
        cat ${SCRIPTS_ROOT}/templates/swag/default | envsubst '$duckdns_domain' > ${SCRIPTS_ROOT}/dockerfiles/swag/default
    fi
fi