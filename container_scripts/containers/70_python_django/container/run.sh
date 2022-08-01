#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "run_django_cont.sh"

source ${PROJECT_SETTINGS}

if [[ "${DEBUG}" == "TRUE" ]]
then
    if [[ "${MOUNT_SRC_CODE}" == "TRUE" ]]
    then
        APP_MOUNTS=""
        echo debug 1 python_django run.sh ls = $(ls ${SRC_CODE_PATH})
        for app_name in $(ls ${SRC_CODE_PATH});
        do 
            echo debug 2 python_django run.sh app_name=${app_name}
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
    else
        p_string="podman run -dit --pod ${POD_NAME} --name ${DJANGO_CONT_NAME} -v ${DJANGO_HOST_STATIC_VOL}:${DJANGO_CONT_STATIC_VOL} -v ${CODE_PATH}:/opt/${PROJECT_NAME}:Z -v /etc/opt/${PROJECT_NAME}/settings:/etc/opt/${PROJECT_NAME}/settings:Z -v ${HOST_LOG_DIR}:${DJANGO_CONT_LOG_DIR}:Z ${DJANGO_IMAGE}"
        runuser --login ${USER_NAME} -P -c "${p_string}"
    fi
else
    runuser --login ${USER_NAME} -P -c "podman run -dit --pod ${POD_NAME} --name ${DJANGO_CONT_NAME}  -v ${DJANGO_HOST_STATIC_VOL}:${DJANGO_CONT_STATIC_VOL}:Z -v ${DJANGO_HOST_MEDIA_VOL}:${DJANGO_CONT_MEDIA_VOL}:Z -v ${CODE_PATH}:/opt/${PROJECT_NAME}:Z -v /etc/opt/${PROJECT_NAME}/settings:/etc/opt/${PROJECT_NAME}/settings:Z -v ${HOST_LOG_DIR}:${DJANGO_CONT_LOG_DIR}:Z ${DJANGO_IMAGE}" # > ${SCRIPTS_ROOT}/systemd/.django_container_id 
fi
## hack to prevent memory issues.  Clamav starts immediately from other container and hogs memory.  This waits until it finishes - moreorless... :)
echo -e "waiting for django to finish starting..."
until [[ $(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}') -le 40 ]] > /dev/null 2>&1
do
    echo -n "."
done