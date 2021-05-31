#!/bin/bash

if [[ ! -f ${HOST_LOG_DIR} ]]
then
    mkdir -p ${HOST_LOG_DIR}
    mkdir ${HOST_LOG_DIR}/django
    mkdir ${HOST_LOG_DIR}/gunicorn
fi

if [[ -z "${CODE_PATH}" ]]
then
	read -p 'Path to code (the django_artisan folder where manage.py resides) : ' CODE_PATH
fi

echo "CODE_PATH is ${CODE_PATH}"
podman container exists ${DJANGO_CONT_NAME};
retval=$?
if [[ $retval -eq 0 ]]
then
	echo Starting container ${DJANGO_CONT_NAME}...
	podman start ${DJANGO_CONT_NAME};
else
	echo ${DJANGO_CONT_NAME} DOESN\'T EXIST, creating....;
	podman run -d -it --pod ${POD_NAME} --name ${DJANGO_CONT_NAME} -v ${DJANGO_HOST_STATIC_VOL}:${DJANGO_CONT_STATIC_VOL} -v ${CODE_PATH}:/opt/${PROJECT_NAME}:Z -v /etc/opt/${PROJECT_NAME}/settings:/etc/opt/${PROJECT_NAME}/settings:Z -v ${HOST_LOG_DIR}:${DJANGO_CONT_LOG_DIR}:Z ${DJANGO_IMAGE} > ${SCRIPTS_ROOT}/systemd/.django_container_id
fi

podman exec -e PROJECT_NAME=${PROJECT_NAME} -d ${DJANGO_CONT_NAME} bash -c "mkdir -p /opt/${PROJECT_NAME}; mkdir -p /var/log/${PROJECT_NAME}; mkdir -p /etc/opt/${PROJECT_NAME}/settings; mkdir -p /etc/opt/${PROJECT_NAME}/static_files;"

podman exec -e PROJECT_NAME=${PROJECT_NAME} -d ${DJANGO_CONT_NAME} bash -c 'echo -e export PYTHONPATH="/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/" >> /root/.bashrc'

podman cp ${SCRIPTS_ROOT}/settings/settings_env ${DJANGO_CONT_NAME}:/etc/opt/${PROJECT_NAME}/settings/.env

rm ${SCRIPTS_ROOT}/settings/settings_env

podman exec -e PROJECT_NAME=${PROJECT_NAME} -d ${DJANGO_CONT_NAME} bash -c "chmod 0400 /etc/opt/${PROJECT_NAME}/settings/.env"

cp ${SCRIPTS_ROOT}/settings/gunicorn.conf.py /etc/opt/${PROJECT_NAME}/settings/
cp ${SCRIPTS_ROOT}/settings/settings.py /etc/opt/${PROJECT_NAME}/settings/

podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH="/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/" -it ${DJANGO_CONT_NAME} bash -c "cd /opt/${PROJECT_NAME}/ && python manage.py collectstatic --noinput && python manage.py migrate --noinput && python manage.py createcachetable;"

if [[ ${DEBUG} == "TRUE" ]]
then
	# runserver
	${TERMINAL_CMD} podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH="/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/" -it ${DJANGO_CONT_NAME} bash -c "cd /opt/${PROJECT_NAME} && python manage.py runserver 0.0.0.0:8000"
	# djangoq qcluster
	${TERMINAL_CMD} podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH="/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/" -it ${DJANGO_CONT_NAME} bash -c "cd /opt/${PROJECT_NAME} && python manage.py qcluster" 
else
    # copy media files to media_root
	podman exec -e PROJECT_NAME=${PROJECT_NAME} -d ${DJANGO_CONT_NAME} bash -c "cp -ar /opt/${PROJECT_NAME}/media /etc/opt/${PROJECT_NAME}/static_files/media;"
	podman cp ${SCRIPTS_ROOT}/settings/supervisor_gunicorn ${DJANGO_CONT_NAME}:/etc/supervisor/conf.d/gunicorn_supervisord.conf
    podman exec -d ${DJANGO_CONT_NAME} bash -c "supervisord"
    #podman exec -e PROJECT_NAME=${PROJECT_NAME} -d  ${DJANGO_CONT_NAME} bash -c "gunicorn -c /etc/opt/${PROJECT_NAME}/settings/gunicorn.conf.py ${DJANGO_PROJECT_NAME}.wsgi:application &"
fi
