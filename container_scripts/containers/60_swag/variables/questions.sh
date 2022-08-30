#!/bin/bash

L_S_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/containers/00_shared/variables/settings.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/get_tag.sh
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/current_dir.sh

if [[ ${DEBUG} == "TRUE" ]]
then
	exit 0
fi

# SWAG_VOL_NAME
swag_vol_name="cert_vol"
read -p "Swag Volume Name [${swag_vol_name}] : " SWAG_VOL_NAME
SWAG_VOL_NAME=${SWAG_VOL_NAME:-${swag_vol_name}}

echo "SWAG_VOL_NAME=${SWAG_VOL_NAME}" >> ${L_S_FILE}

# CERTBOT_EMAIL
read -p "Email address for letsencrypt certbot : " certbot_email

echo "CERTBOT_EMAIL=${certbot_email}" >> ${L_S_FILE}

# SWAG_HOST_LOG_DIR
swhld="${USER_DIR}/${PROJECT_NAME}/swag_logs"
read -p "Swag Host log dir (must be different to Host Log Dir) [ ${swhld} ] : " SWAG_HOST_LOG_DIR
SWAG_HOST_LOG_DIR=${SWAG_HOST_LOG_DIR:-${swhld}}

echo "SWAG_HOST_LOG_DIR=${SWAG_HOST_LOG_DIR}" >> ${L_S_FILE}

# EXTRA_DOMAINS
echo -e "\nDo you have a top level domain pointing at your duckdns domain ? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) tldomain="TRUE"; break;;
        No ) tldomain="FALSE"; break;;
    esac
done
if [[ ${tldomain} == "TRUE" ]]
then
    read -p "Your top level domain that points at your duckdns domain : " tl_domain
    EXTRA_DOMAINS="${tl_domain}"
else
    EXTRA_DOMAINS="NONE"
fi

echo "EXTRA_DOMAINS=${EXTRA_DOMAINS}" >> ${L_S_FILE}

# SWAG_CONT_NAME

SWAG_CONT_NAME="redis_cont"

echo "SWAG_CONT_NAME=${SWAG_CONT_NAME}" >> ${L_S_FILE}

# SWAG_IMAGE

SWAG_IMAGE=$(get_tag ${CURRENT_DIR})

echo "SWAG_IMAGE=${SWAG_IMAGE}" >> ${L_S_FILE}

# SWAG_CONT_VOL_STATIC
SWAG_CONT_VOL_STATIC="/opt/static_files/"

echo "SWAG_CONT_VOL_STATIC=${SWAG_CONT_VOL_STATIC}" >> ${L_S_FILE}

# SWAG_CONT_VOL_MEDIA
SWAG_CONT_VOL_MEDIA="/opt/media_files/"

echo "SWAG_CONT_VOL_MEDIA=${SWAG_CONT_VOL_MEDIA}" >> ${L_S_FILE}

# SWAG_CONT_LOG_DIR
SWAG_CONT_LOG_DIR="/config/log/"

echo "SWAG_CONT_LOG_DIR=${SWAG_CONT_LOG_DIR}" >> ${L_S_FILE}