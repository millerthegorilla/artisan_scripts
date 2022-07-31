#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

if [[ "${DEBUG}" == "TRUE" ]]
then
    exit 0
fi

if [[ ${TLDOMAIN} == "TRUE" ]]
then
	runuser --login ${USER_NAME} -P -c "podman run -dit --pod=${POD_NAME}  --secret=DUCKDNS_TOKEN,type=env,target=DUCKDNS_TOKEN --name=${SWAG_CONT_NAME} --cap-add=NET_ADMIN -e PUID=1000 -e PGID=1000 -e TZ=\"Europe/London\" -e URL=${DUCKDNS_DOMAIN} -e ENAIL=${CERTBOT_EMAIL} -e VALIDATION=duckdns -e EXTRA_DOMAINS=${EXTRA_DOMAINS} -e STAGING=$staging -v ${SWAG_HOST_VOL_STATIC}:${SWAG_CONT_VOL_STATIC}:Z -v ${SWAG_VOL_NAME}:/config/:Z ${SWAG_IMAGE}"
else
	runuser --login ${USER_NAME} -P -c "podman run -dit --pod=${POD_NAME}  --secret=DUCKDNS_TOKEN,type=env,target=DUCKDNS_TOKEN --name=${SWAG_CONT_NAME} --cap-add=NET_ADMIN -e PUID=1000 -e PGID=1000 -e TZ=\"Europe/London\" -e URL=${DUCKDNS_DOMAIN} -e EMAIL=${CERTBOT_EMAIL} -e VALIDATION=duckdns -e STAGING=$staging -v ${SWAG_HOST_VOL_STATIC}:${SWAG_CONT_VOL_STATIC}:Z -v ${DJANGO_HOST_MEDIA_VOL}:${SWAG_CONT_VOL_MEDIA} -v ${SWAG_HOST_LOG_DIR}:${SWAG_CONT_LOG_DIR}:Z -v ${SWAG_VOL_NAME}:/config/:Z ${SWAG_IMAGE}"
fi