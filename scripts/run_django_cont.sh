#!/bin/bash

if [[ ! -f ${HOST_LOG_DIR} ]]
then
    mkdir -p ${HOST_LOG_DIR}
    mkdir ${HOST_LOG_DIR}/django
    mkdir ${HOST_LOG_DIR}/gunicorn
fi

podman container exists ${DJANGO_CONT_NAME};
retval=$?
if [[ $retval -eq 0 ]]
then
	echo Starting container ${DJANGO_CONT_NAME}...
	podman start ${DJANGO_CONT_NAME};
else
	echo ${DJANGO_CONT_NAME} DOESN\'T EXIST, creating....;
	podman run -d -it --pod ${POD_NAME} --name ${DJANGO_CONT_NAME} -v /opt/${PROJECT_NAME}:/opt/${PROJECT_NAME}:Z -v /etc/opt/${PROJECT_NAME}/settings:/etc/opt/${PROJECT_NAME}/settings:Z -v ${HOST_LOG_DIR}:${DJANGO_CONT_LOG_DIR}:Z ${DJANGO_IMAGE}
fi

cat ${SCRIPTS_ROOT}/templates/gunicorn.conf.py | envsubst > ${SCRIPTS_ROOT}/settings/gunicorn.conf.py

podman cp ${SCRIPTS_ROOT}/settings/settings_env ${DJANGO_CONT_NAME}:/etc/opt/${PROJECT_NAME}/settings/.env

rm ${SCRIPTS_ROOT}/settings/settings_env

podman exec -e PROJECT_NAME=${PROJECT_NAME} -d ${DJANGO_CONT_NAME} bash -c "chmod 0400 /etc/opt/${PROJECT_NAME}/settings/.env"

cp ${SCRIPTS_ROOT}/settings/gunicorn.conf.py /etc/opt/${PROJECT_NAME}/settings/
cp ${SCRIPTS_ROOT}/settings/settings.py /etc/opt/${PROJECT_NAME}/settings/

# podman exec -d ${DJANGO_CONT_NAME} bash -c "mkdir -p /var/log/${PROJECT_NAME}/gunicorn"

podman exec -e PROJECT_NAME=${PROJECT_NAME} -d ${DJANGO_CONT_NAME} bash -c "cd /opt/${PROJECT_NAME}/; python manage.py collectstatic; python manage.py migrate; python manage.py createcachetable"

podman exec -e PROJECT_NAME=${PROJECT_NAME} -d  ${DJANGO_CONT_NAME} bash -c "gunicorn -c /etc/opt/${PROJECT_NAME}/settings/gunicorn.conf.py ceramic_isles.wsgi:application &"
