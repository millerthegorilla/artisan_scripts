#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "$(basename ${0})"

source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.proj

if [[ -n "${SWAG_HOST_LOG_DIR}" && ! -f ${SWAG_HOST_LOG_DIR} ]]
then
    mkdir -p ${SWAG_HOST_LOG_DIR}
    chown ${USER_NAME}:${USER_NAME} ${SWAG_HOST_LOG_DIR}
fi

echo -e "\n\nIs the project 'pre-production'?  If it is then the swag container can be created with a 'staging' flag, that will see certificate requests sent to the lets encrypt staging api.  Doing this will prevent any rate-limits set by lets encrypt.  Note though, that to place the site into production, you will need to recreate the swag container with this staging flag set to false.\nhttps://letsencrypt.org/docs/staging-environment/\n"
echo -e "Set staging to True?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) staging=True; break;;
        No ) staging=False; break;;
    esac
done

if [[ ${TLDOMAIN} == "TRUE" ]]
then
	runuser --login ${USER_NAME} -P -c "podman run -dit --pod=${POD_NAME}  --secret=DUCKDNSTOKEN,type=env --name=${SWAG_CONT_NAME} --cap-add=NET_ADMIN -e PUID=1000 -e PGID=1000 -e TZ=\"Europe/London\" -e URL=${DUCKDNS_SUBDOMAIN}  -e VALIDATION=duckdns -e EXTRA_DOMAINS=${EXTRA_DOMAINS} -e STAGING=$staging -v ${SWAG_HOST_VOL_STATIC}:${SWAG_CONT_VOL_STATIC}:Z -v ${SWAG_HOST_LOG_DIR}:${SWAG_CONT_LOG_DIR}:Z -v ${SWAG_VOL_NAME}:/le-ssl/letsencrypt/live/${DUCKDNS_SUBDOMAIN}/:Z --restart unless-stopped ${SWAG_IMAGE}"
else
	runuser --login ${USER_NAME} -P -c "podman run -dit --pod=${POD_NAME}  --secret=DUCKDNSTOKEN,type=env --name=${SWAG_CONT_NAME} --cap-add=NET_ADMIN -e PUID=1000 -e PGID=1000 -e TZ=\"Europe/London\" -e URL=${DUCKDNS_SUBDOMAIN}  -e VALIDATION=duckdns -e STAGING=$staging -v ${SWAG_HOST_VOL_STATIC}:${SWAG_CONT_VOL_STATIC}:Z -v ${SWAG_HOST_LOG_DIR}:${SWAG_CONT_LOG_DIR}:Z --restart unless-stopped ${SWAG_IMAGE}"
fi