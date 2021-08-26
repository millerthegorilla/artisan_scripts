#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "run_django_cont.sh"

source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.archive
source ${SCRIPTS_ROOT}/options
source ${SCRIPTS_ROOT}/.proj

cp ${SCRIPTS_ROOT}/settings/settings_env /etc/opt/${PROJECT_NAME}/settings/.env

chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings/.env
chmod 0400 /etc/opt/${PROJECT_NAME}/settings/.env

rm ${SCRIPTS_ROOT}/settings/settings_env

if [[ "${DEBUG}" == "FALSE" ]]
then
    cp ${SCRIPTS_ROOT}/settings/gunicorn.conf.py /etc/opt/${PROJECT_NAME}/settings/
    chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings/gunicorn.conf.py
fi
cp ${SCRIPTS_ROOT}/settings/settings.py /etc/opt/${PROJECT_NAME}/settings/
chown ${USER_NAME}:${USER_NAME} /etc/opt/${PROJECT_NAME}/settings/settings.py

runuser --login ${USER_NAME} -P -c "podman run -dit --pod ${POD_NAME} --name ${DJANGO_CONT_NAME} -v ${DJANGO_HOST_STATIC_VOL}:${DJANGO_CONT_STATIC_VOL} -v ${CODE_PATH}:/opt/${PROJECT_NAME}:Z -v /etc/opt/${PROJECT_NAME}/settings:/etc/opt/${PROJECT_NAME}/settings:Z -v ${HOST_LOG_DIR}:${DJANGO_CONT_LOG_DIR}:Z --restart unless-stopped ${DJANGO_IMAGE}" # > ${SCRIPTS_ROOT}/systemd/.django_container_id 

## hack to prevent memory issues.  Clamav starts immediately from other container and hogs memory.  This waits until it finishes - moreorless... :)
echo -e "waiting for django to finish starting..."
until [[ $(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}') -le 40 ]] > /dev/null 2>&1
do
    echo -n "."
done

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
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /opt/${PROJECT_NAME}&& find /opt/${PROJECT_NAME} -type d -exec chmod 0550 {} + && find /opt/${PROJECT_NAME} -type f -exec chmod 0440 {} +\""
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /etc/opt/${PROJECT_NAME} && find /etc/opt/${PROJECT_NAME} -type f -exec chmod 0440 {} + && find /etc/opt/${PROJECT_NAME} -type d -exec chmod 0550 {} +\""
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"touch /var/log/${PROJECT_NAME}/django/debug.log && chown artisan:artisan /var/log/${PROJECT_NAME}/django/debug.log\""
    # copy media files to media_root
  #  echo -e "starting gunicorn"
   # podman exec -d ${DJANGO_CONT_NAME} bash -c "supervisorctl start gunicorn"
    #podman exec -e PROJECT_NAME=${PROJECT_NAME} -d  ${DJANGO_CONT_NAME} bash -c "gunicorn -c /etc/opt/${PROJECT_NAME}/settings/gunicorn.conf.py ${DJANGO_PROJECT_NAME}.wsgi:application &"
fi
