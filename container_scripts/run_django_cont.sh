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

if [[ "${DEBUG}" == "TRUE" ]]
then
    if [[ "${MOUNT_SRC_CODE}" == "TRUE" ]]
    then
        APP_MOUNTS=""
        for app_name in $(ls ${SRC_CODE_PATH});
        do  
            APP_MOUNTS="${APP_MOUNTS} -v ${SRC_CODE_PATH}/${app_name}/${app_name}:/opt/${PROJECT_NAME}/${app_name}:Z"
        done
        p_string="podman run -dit --pod ${POD_NAME} --name ${DJANGO_CONT_NAME} -v ${DJANGO_HOST_STATIC_VOL}:${DJANGO_CONT_STATIC_VOL} ${APP_MOUNTS} -v ${CODE_PATH}:/opt/${PROJECT_NAME}:Z -v /etc/opt/${PROJECT_NAME}/settings:/etc/opt/${PROJECT_NAME}/settings:Z -v ${HOST_LOG_DIR}:${DJANGO_CONT_LOG_DIR}:Z ${DJANGO_IMAGE}"
        
        runuser --login ${USER_NAME} -P -c "${p_string}"
        for app_name in $(ls ${SRC_CODE_PATH});
        do 
            if [[ "${MOUNT_GIT}" == "FALSE" ]]
            then
                runuser --login ${USER_NAME} -P -c "ln -s ${SRC_CODE_PATH}${app_name}/${app_name} ${CODE_PATH}/${app_name}_src"
            else
                runuser --login ${USER_NAME} -P -c "ln -s ${SRC_CODE_PATH}${app_name} ${CODE_PATH}/${app_name}_git"
            fi
        done
    fi 
else
    cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/media/* ${DJANGO_HOST_MEDIA_VOL}media

    runuser --login ${USER_NAME} -P -c "podman run -dit --pod ${POD_NAME} --name ${DJANGO_CONT_NAME} -v ${DJANGO_HOST_STATIC_VOL}:${DJANGO_CONT_STATIC_VOL}:Z -v ${DJANGO_HOST_MEDIA_VOL}:${DJANGO_CONT_MEDIA_VOL}:Z -v ${CODE_PATH}:/opt/${PROJECT_NAME}:Z -v /etc/opt/${PROJECT_NAME}/settings:/etc/opt/${PROJECT_NAME}/settings:Z -v ${HOST_LOG_DIR}:${DJANGO_CONT_LOG_DIR}:Z ${DJANGO_IMAGE}" # > ${SCRIPTS_ROOT}/systemd/.django_container_id 
fi
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
    cp -ar ${SCRIPTS_ROOT}/dockerfiles/django/media /home/${USER_NAME}
    runuser --login ${USER_NAME} -P -c "podman cp ~/media /etc/opt/${PROJECT_NAME}/media_files/"
    rm -rf /home/${USER_NAME}/media
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /opt/${PROJECT_NAME}&& find /opt/${PROJECT_NAME} -type d -exec chmod 0550 {} + && find /opt/${PROJECT_NAME} -type f -exec chmod 0440 {} +\""
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /etc/opt/${PROJECT_NAME} && find /etc/opt/${PROJECT_NAME} -type f -exec chmod 0440 {} + && find /etc/opt/${PROJECT_NAME} -type d -exec chmod 0550 {} +\""
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chmod 0770 /etc/opt/${PROJECT_NAME}/static_files && find /etc/opt/${PROJECT_NAME}/static_files -type f -exec chmod 0660 {} + && find /etc/opt/${PROJECT_NAME}/static_files -type d -exec chmod 0770 {} +\""
    runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chmod 0770 /etc/opt/${PROJECT_NAME}/media_files && find /etc/opt/${PROJECT_NAME}/media_files -type f -exec chmod 0660 {} + && find /etc/opt/${PROJECT_NAME}/media_files -type d -exec chmod 0770 {} +\""
    
    #runuser --login ${USER_NAME} -P -c "podman cp ${SCRIPTS_ROOT}/dockerfiles/django/media ${DJANGO_CONT_NAME}:${DJANGO_CONT_MEDIA_VOL}"
fi
