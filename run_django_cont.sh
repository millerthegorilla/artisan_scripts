#!/bin/bash

podman container exists ${DJANGO_CONT_NAME};
retval=$?
if [[ $retval -eq 0 ]]
then
	echo Starting container ${DJANGO_CONT_NAME}...
	podman start ${DJANGO_CONT_NAME};
else
	echo ${DJANGO_CONT_NAME} DOESN\'T EXIST, creating....;
	podman run -d -it --pod ${POD_NAME} --name ${DJANGO_CONT_NAME} -v /opt/${PROJECT_NAME}:/opt/${PROJECT_NAME}:Z -v /etc/opt/${PROJECT_NAME}/settings:/etc/opt/${PROJECT_NAME}/settings:Z -v ${HOST_LOG_DIR}:${DJANGO_LOG_DIR}:Z ${DJANGO_IMAGE}
fi

cat ./templates/gunicorn.conf.py | envsubst >> settings/gunicorn.conf.py

cp settings/gunicorn.conf.py /etc/opt/${PROJECT_NAME}/settings/
cp settings/settings.py /etc/opt/${PROJECT_NAME}/settings/

podman exec -it django_cont bash -c "cd /opt/${PROJECT_NAME}/; python manage.py collectstatic; python manage.py migrate; python manage.py createcachetable; python manage.py search_index --rebuild;"
