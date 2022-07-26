#!/bin/bash

L_S_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh

# XDESK
if [[ $(type Xorg > /dev/null 2>&1 | echo $?) -eq 0 ]]
then
    XDESK="XDG_RUNTIME_DIR=\"/run/user/$(id -u ${USER_NAME})\" DBUS_SESSION_BUS_ADDRESS=\"unix:path=${XDG_RUNTIME_DIR}/bus\""
else
    XDESK=""
fi

echo "XDESK=${XDESK}" >> ${L_S_FILE}

# MOUNT_SRC_CODE
echo -e 'mount app source code directories? - note that repository name must be indentical to the contained app name.'
select yn in "Yes" "No"; do
    case $yn in
        Yes ) MOUNT_SRC_CODE="TRUE"; break;;
        No ) MOUNT_SRC_CODE="FALSE"; break;;
    esac
done

echo "MOUNT_SRC_CODE=${MOUNT_SRC_CODE}" >> ${L_S_FILE}

# MOUNT_GIT
if [[ ${MOUNT_SRC_CODE} == "TRUE" ]]
then
    echo -e 'mount source code directories (1) or mount git directories (2)'
    select sg in "src" "git"; do
        case $sg in
            src ) MOUNT_GIT="FALSE"; break;;
            git ) MOUNT_GIT="TRUE"; break;;
        esac
    done
fi

echo "MOUNT_GIT=${MOUNT_GIT}" >> ${L_S_FILE}

# BASE_DIR
# base dir is used in settings_env for base_dir in settings.py
bn="/opt/${PROJECT_NAME}/"
read -p "Container base code directory [${bn}] : " BASE_DIR
BASE_DIR=${BASE_DIR:-${bn}}

echo "BASE_DIR=${BASE_DIR}" >> ${L_S_FILE}

# STATIC_BASE_ROOT 
# is mounted in container
if [[ ${DEBUG} == "TRUE" ]]
then
    SBR="/opt/${PROJECT_NAME}/"
else
    SBR="/etc/opt/${PROJECT_NAME}/static_files/"
fi

read -p "Static base root [${SBR}] : " STATIC_BASE_ROOT
STATIC_BASE_ROOT=${STATIC_BASE_ROOT:-${SBR}}

echo "STATIC_BASE_ROOT=${STATIC_BASE_ROOT}" >> ${L_S_FILE}

# MEDIA_BASE_ROOT
if [[ ${DEBUG} == "TRUE" ]]
then
    MBR="/opt/${project_name}/"
else
    MBR="/etc/opt/${project_name}/media_files/"
fi
read -p "Media base root [${MBR}] : " MEDIA_BASE_ROOT
MEDIA_BASE_ROOT=${MEDIA_BASE_ROOT:-${MBR}}

echo "MEDIA_BASE_ROOT=${MEDIA_BASE_ROOT}"

# HOST_LOG_DIR
read -p "Host log dir [${USER_DIR}/${PROJECT_NAME}/logs] : " HOST_LOG_DIR
HOST_LOG_DIR=${HOST_LOG_DIR:-${USER_DIR}/${PROJECT_NAME}/logs}

echo "HOST_LOG_DIR=${HOST_LOG_DIR}" >> ${L_S_FILE}

# HOST_STATIC_DIR
# host static dir mounts on to static base root from django and swag conts.
HOST_STATIC_DIR=/etc/opt/${PROJECT_NAME}/static_files/

echo "HOST_STATIC_DIR=${HOST_STATIC_DIR}" >> ${L_S_FILE}

# HOST_MEDIA_DIR
HOST_MEDIA_DIR=/etc/opt/${PROJECT_NAME}/media_files/

echo "HOST_MEDIA_DIR=${HOST_MEDIA_DIR}" >> ${L_S_FILE}

## SECRET KEYGEN
DJANGO_SECRET_KEY=$(tr -dc 'a-z0-9!@#$%^&*(-_=+)' < /dev/urandom | head -c50)

echo "DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}"

# DJANGO_CONT_NAME

DJANGO_CONT_NAME="redis_cont"

echo "DJANGO_CONT_NAME=${DJANGO_CONT_NAME}" >> ${L_S_FILE}

# DJANGO_IMAGE
DJANGO_IMAGE=$(get_tag $BASH_SOURCE)

echo "DJANGO_IMAGE=${DJANGO_IMAGE}" >> ${L_S_FILE}