#!/bin/bash

L_S_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/containers/00_shared/variables/settings.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

# XDESK
if [[ $(type Xorg > /dev/null 2>&1 | echo $?) -eq 0 ]]
then
    XDESK="XDG_RUNTIME_DIR=\"/run/user/$(id -u ${USER_NAME})\" DBUS_SESSION_BUS_ADDRESS=\"unix:path=${XDG_RUNTIME_DIR}/bus\""
else
    XDESK=""
fi

echo "XDESK=${XDESK}" >> ${L_S_FILE}

# BASE_DIR
# base dir is used in settings_env for base_dir in settings.py
bn="/opt/${PROJECT_NAME}/"
read -p "Path to codebase inside container [${bn}] : " BASE_DIR
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
    MBR="/opt/${PROJECT_NAME}/"
else
    MBR="/etc/opt/${PROJECT_NAME}/media_files/"
fi
read -p "Media base root [${MBR}] : " MEDIA_BASE_ROOT
MEDIA_BASE_ROOT=${MEDIA_BASE_ROOT:-${MBR}}

echo "MEDIA_BASE_ROOT=${MEDIA_BASE_ROOT}" >> ${L_S_FILE}

# HOST_LOG_DIR
read -p "Host log dir [${USER_DIR}/${PROJECT_NAME}/logs] : " HOST_LOG_DIR
HOST_LOG_DIR=${HOST_LOG_DIR:-${USER_DIR}/${PROJECT_NAME}/logs}

echo "HOST_LOG_DIR=${HOST_LOG_DIR}" >> ${L_S_FILE}

# CONT_LOG_DIR
DJANGO_CONT_LOG_DIR="/var/log/${PROJECT_NAME}/"

echo "DJANGO_CONT_LOG_DIR=${DJANGO_CONT_LOG_DIR}" >> ${L_S_FILE}

# DJANGO_HOST_STATIC_VOL
# host static vol mounts on to static base root from django and swag conts.
DJANGO_HOST_STATIC_VOL=/etc/opt/${PROJECT_NAME}/static_files/

echo "DJANGO_HOST_STATIC_VOL=${DJANGO_HOST_STATIC_VOL}" >> ${L_S_FILE}

# DJANGO_CONT_STATIC_VOL
DJANGO_CONT_STATIC_VOL=${DJANGO_HOST_STATIC_VOL}

echo "DJANGO_CONT_STATIC_VOL=${DJANGO_CONT_STATIC_VOL}" >> ${L_S_FILE}

# DJANGO_HOST_MEDIA_VOL
DJANGO_HOST_MEDIA_VOL=/etc/opt/${PROJECT_NAME}/media_files/

echo "DJANGO_HOST_MEDIA_VOL=${DJANGO_HOST_MEDIA_VOL}" >> ${L_S_FILE}

# DJANGO_CONT_MEDIA_VOL
DJANGO_CONT_MEDIA_VOL=${DJANGO_HOST_MEDIA_VOL}

echo "DJANGO_CONT_MEDIA_VOL=${DJANGO_CONT_MEDIA_VOL}" >> ${L_S_FILE}

## DJANGO_SECRET_KEYGEN
DJANGO_SECRET_KEY="$(tr -dc 'a-z0-9!@#$%^&*(-_=+)' < /dev/random | head -c50)"

echo "DJANGO_SECRET_KEY=\"${DJANGO_SECRET_KEY}\"" >> ${L_S_FILE}

# DJANGO_CONT_NAME
DJANGO_CONT_NAME="django_cont"

echo "DJANGO_CONT_NAME=${DJANGO_CONT_NAME}" >> ${L_S_FILE}

# DJANGO_IMAGE
DJANGO_IMAGE=$(get_tag ${CURRENT_DIR})

echo "DJANGO_IMAGE=${DJANGO_IMAGE}" >> ${L_S_FILE}

# DOCKERFILE_APP_NAMES
if [[ ${DEBUG} == "TRUE" ]]
then
    echo -e 'mount app source code directories? - note that repository name must be indentical to the contained app name.'
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) MOUNT_SRC_CODE="TRUE"; break;;
            No ) MOUNT_SRC_CODE="FALSE"; break;;
        esac
    done
    if [[ ${MOUNT_SRC_CODE} == "TRUE" ]]
    then
        cd /
        until [[ -d "${SRC_CODE_PATH}" && ! -L "${SRC_CODE_PATH}" ]] 
        do
            echo -e 'mount source code directories (1) or mount git directories (2)'
            select sg in "src" "git"; do
                case $sg in
                    src ) MOUNT_GIT="FALSE"; break;;
                    git ) MOUNT_GIT="TRUE"; break;;
                esac
            done
            if [[ ${MOUNT_GIT} == "TRUE" ]]
            then
                SMSG='Symlinks will be to the git repository which can allow you to use git submodules to track your code changes.'
            else
                SMSG='Symlinks will be to the source code directories inside the git repository.  You will have to manually track source code changes, updating each git in each repository.'
            fi
            echo -e 'Absolute path to git repository (the folder where your app directories reside) - *IMPORTANT* There must only be git repository directories at this path, ie each subdirectory of this path must be of the form "app_name" which must be a git repository for your app, and must have the subdirectory "app_name" containing the django_source_code.'
            echo -e ${SMSG}
            read -p ":" -e SRC_CODE_PATH
            if [[ ! -d "${SRC_CODE_PATH}" ]]
            then
               echo -e "That path doesn't exist!"
            fi
            if [[ -L "${SRC_CODE_PATH}" ]]
            then
                echo -e "Code path must not be a symbolic link"
            fi
        done
        # constructs a dockerfile RUN command that makes the various directories for the source code
        DOCKERFILE_APP_NAMES="RUN "
        for app_name in $(ls ${SRC_CODE_PATH});
        do 
             DOCKERFILE_APP_NAMES="${DOCKERFILE_APP_NAMES}; mkdir -p /opt/${PROJECT_NAME}/${app_name}; "
        done
    fi
fi

echo "DOCKERFILE_APP_NAMES=\"${DOCKERFILE_APP_NAMES}\"" >> ${L_S_FILE}

# MOUNT_SRC_CODE
echo "MOUNT_SRC_CODE=${MOUNT_SRC_CODE}" >> ${L_S_FILE}

# MOUNT_GIT
echo "MOUNT_GIT=${MOUNT_GIT}" >> ${L_S_FILE}

# SRC_CODE_PATH
echo "SRC_CODE_PATH=${SRC_CODE_PATH}" >> ${L_S_FILE}
