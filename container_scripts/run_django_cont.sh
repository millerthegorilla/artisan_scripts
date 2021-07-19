#!/bin/bash


cp ${SCRIPTS_ROOT}/settings/settings_env /etc/opt/${PROJECT_NAME}/settings/.env

rm ${SCRIPTS_ROOT}/settings/settings_env

chmod 0400 /etc/opt/${PROJECT_NAME}/settings/.env

cp ${SCRIPTS_ROOT}/settings/gunicorn.conf.py /etc/opt/${PROJECT_NAME}/settings/
cp ${SCRIPTS_ROOT}/settings/settings.py /etc/opt/${PROJECT_NAME}/settings/

podman run -d -it --pod ${POD_NAME} --name ${DJANGO_CONT_NAME} -v ${DJANGO_HOST_STATIC_VOL}:${DJANGO_CONT_STATIC_VOL} -v ${CODE_PATH}:/opt/${PROJECT_NAME}:Z -v /etc/opt/${PROJECT_NAME}/settings:/etc/opt/${PROJECT_NAME}/settings:Z -v ${HOST_LOG_DIR}:${DJANGO_CONT_LOG_DIR}:Z ${DJANGO_IMAGE} > ${SCRIPTS_ROOT}/systemd/.django_container_id

podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH="/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/" -it ${DJANGO_CONT_NAME} bash -c "cd /opt/${PROJECT_NAME}/ && python manage.py collectstatic --noinput && python manage.py migrate --noinput && python manage.py createcachetable;"

if [[ "${DEBUG}" == "TRUE" ]]
then
	echo -e "creating manage and qcluster"
	${TERMINAL_CMD} podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH="/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/" -it ${DJANGO_CONT_NAME} bash -c "cd /home/artisan/django_venv; source bin/activate; python /opt/\${PROJECT_NAME}/manage.py runserver 0.0.0.0:8000"
	${TERMINAL_CMD} podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH="/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/" -it ${DJANGO_CONT_NAME} bash -c "cd /home/artisan/django_venv; source bin/activate; python /opt/\${PROJECT_NAME}/manage.py qcluster"
else
	## change everything to artisan:artisan
    podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c "chown artisan:artisan -R /opt/${PROJECT_NAME}&& find /opt/${PROJECT_NAME} -type d -exec chmod 0550 {} + && find /opt/${PROJECT_NAME} -type f -exec chmod 0440 {} + "
    podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c "chown artisan:artisan -R /etc/opt/${PROJECT_NAME} && find /etc/opt/${PROJECT_NAME} -type f -exec chmod 0440 {} + && find /etc/opt/${PROJECT_NAME} -type d -exec chmod 0550 {} +"
    podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c "touch /var/log/${PROJECT_NAME}/django/debug.log && chown artisan:artisan /var/log/${PROJECT_NAME}/django/debug.log"
    # copy media files to media_root
  #  echo -e "starting gunicorn"
   # podman exec -d ${DJANGO_CONT_NAME} bash -c "supervisorctl start gunicorn"
    #podman exec -e PROJECT_NAME=${PROJECT_NAME} -d  ${DJANGO_CONT_NAME} bash -c "gunicorn -c /etc/opt/${PROJECT_NAME}/settings/gunicorn.conf.py ${DJANGO_PROJECT_NAME}.wsgi:application &"
fi
