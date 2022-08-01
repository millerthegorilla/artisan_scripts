#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH=\"/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/\" -it ${DJANGO_CONT_NAME} bash -c \"cd /opt/${PROJECT_NAME}/ && python manage.py collectstatic --noinput && python manage.py migrate --noinput && python manage.py createcachetable;\""

if [[ "${DEBUG}" == "TRUE" ]]
then
	echo -e "creating manage and qcluster"
	if [[ ! $(runuser --login ${USER_NAME} -P -c "${XDESK} ${TERMINAL_CMD} podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH=\"/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/\" -it ${DJANGO_CONT_NAME} bash -c \"cd /home/artisan/django_venv; source bin/activate; python /opt/${PROJECT_NAME}/manage.py runserver 0.0.0.0:8000\"" > /dev/null 2>&1; echo $?) -eq 0 ]]
  then
     openvt -- runuser --login ${USER_NAME} -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH=\"/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/\" -it ${DJANGO_CONT_NAME} bash -c \"cd /home/artisan/django_venv; source bin/activate; python /opt/${PROJECT_NAME}/manage.py runserver 0.0.0.0:8000 &>/tmp/manage_output\" &"
  fi
	if [[ ! $(runuser --login ${USER_NAME} -P -c "${XDESK} ${TERMINAL_CMD} podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH=\"/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/\" -it ${DJANGO_CONT_NAME} bash -c \"cd /home/artisan/django_venv; source bin/activate; python /opt/${PROJECT_NAME}/manage.py qcluster\""> /dev/null 2>&1; echo $?) -eq 0 ]]
  then
      openvt -- runuser --login ${USER_NAME} -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH=\"/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/\" -it ${DJANGO_CONT_NAME} bash -c \"cd /home/artisan/django_venv; source bin/activate; python /opt/${PROJECT_NAME}/manage.py qcluster &>/tmp/manage_output\" &"
  fi
  wait
else
	## change everything to artisan:artisan - probably do this debug or not TODO
    cp -ar ${SCRIPTS_ROOT}/dockerfile/django/media /tmp
    chown ${USER_NAME}:${USER_NAME} -R /tmp/media
    runuser --login ${USER_NAME} -P -c "podman cp /tmp/media ${DJANGO_CONT_NAME}:/etc/opt/${PROJECT_NAME}/media_files/"
    rm -rf /tmp/media
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /opt/${PROJECT_NAME}&& find /opt/${PROJECT_NAME} -type d -exec chmod 0550 {} + && find /opt/${PROJECT_NAME} -type f -exec chmod 0440 {} +\""
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /etc/opt/${PROJECT_NAME} && find /etc/opt/${PROJECT_NAME} -type f -exec chmod 0440 {} + && find /etc/opt/${PROJECT_NAME} -type d -exec chmod 0550 {} +\""
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chmod 0770 /etc/opt/${PROJECT_NAME}/static_files && find /etc/opt/${PROJECT_NAME}/static_files -type f -exec chmod 0660 {} + && find /etc/opt/${PROJECT_NAME}/static_files -type d -exec chmod 0770 {} +\""
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chmod 0770 /etc/opt/${PROJECT_NAME}/media_files && find /etc/opt/${PROJECT_NAME}/media_files -type f -exec chmod 0660 {} + && find /etc/opt/${PROJECT_NAME}/media_files -type d -exec chmod 0770 {} +\""
fi
