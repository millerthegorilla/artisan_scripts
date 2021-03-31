#!/bin/bash

podman container exists ${DJANGO_CONT_NAME};
retval=$?
if [[ $retval -eq 0 ]]
then
	echo Starting container ${DJANGO_CONT_NAME}...
	podman start ${DJANGO_CONT_NAME};
else
	echo ${DJANGO_CONT_NAME} DOESN\'T EXIST, creating....;
	podman run -d -it --pod ${POD_NAME} --name ${DJANGO_CONT_NAME} -v /opt/${DJANGO_PROJECT_NAME}:/opt/${DJANGO_PROJECT_NAME}:Z -v /etc/opt/${DJANGO_PROJECT_NAME}:/etc/opt/${DJANGO_PROJECT_NAME}:Z -v ${HOST_LOG_DIR}:${DJANGO_LOG_DIR}:Z ${DJANGO_IMAGE}
fi

podman exec -it django_cont bash -c "cd /opt/${DJANGO_PROJECT_NAME}/; python manage.py collectstatic; python manage.py migrate; python manage.py createcachetable; python manage.py search_index --rebuild;"
