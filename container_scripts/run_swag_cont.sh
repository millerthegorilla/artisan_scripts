#!/bin/bash

if [[ -n "${SWAG_HOST_LOG_DIR}" && ! -f ${SWAG_HOST_LOG_DIR} ]]
then
    mkdir -p ${SWAG_HOST_LOG_DIR}
fi

echo -e "Is the project 'pre-production'?  If it is then the swag container can be created with a 'staging' flag, that will see certificate requests sent to the lets encrypt staging api.  Doing this will prevent any rate-limits set by lets encrypt.  Note though, that to place the site into production, you will need to recreate the swag container with this staging flag set to false.\nhttps://letsencrypt.org/docs/staging-environment/\n"
echo -e "Set staging to True?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) staging=True; break;;
        No ) staging=False; break;;
    esac
done

podman run -dit --pod=${POD_NAME} --name=${SWAG_CONT_NAME} --cap-add=NET_ADMIN -e PUID=1000 -e PGID=1000 -e TZ=Europe/London -e URL=${DUCKDNS_SUBDOMAIN}  -e VALIDATION=duckdns -e DUCKDNSTOKEN=${DUCKDNS_TOKEN} -e EXTRA_DOMAINS=${EXTRA_DOMAINS} -e STAGING=$staging -v ${SWAG_HOST_VOL_STATIC}:${SWAG_CONT_VOL_STATIC}:Z -v ${SWAG_HOST_LOG_DIR}:${SWAG_CONT_LOG_DIR}:Z --restart unless-stopped ${SWAG_IMAGE}

cat ${SCRIPTS_ROOT}/templates/default | envsubst '${EXTRA_DOMAINS} ${DUCKDNS_SUBDOMAIN}' > ${SCRIPTS_ROOT}/swag/default

echo -e "Waiting for swag container to be ready.."
until podman exec -it ${SWAG_CONT_NAME} bash -c "ls /config/nginx/site-confs/default" &>/dev/null;
do
  echo -n "."
done

echo -e "\n"

podman exec -d ${SWAG_CONT_NAME} bash -c "rm -rf /var/run/s6/etc/services.d/php-fpm"

podman cp ${SCRIPTS_ROOT}/swag/default ${SWAG_CONT_NAME}:/config/nginx/site-confs/default
podman cp ${SCRIPTS_ROOT}/swag/nginx ${SWAG_CONT_NAME}:/config/nginx/nginx.conf
podman exec -d ${SWAG_CONT_NAME} bash -c "chown abc:users /config/nginx/nginx.conf"
podman exec -d ${SWAG_CONT_NAME} bash -c "chown abc:users /config/nginx/site-confs/default"
podman exec -d ${SWAG_CONT_NAME} bash -c "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old"
podman exec -d ${SWAG_CONT_NAME} bash -c "ln -s /config/nginx/nginx.conf /etc/nginx/nginx.conf"

podman stop ${SWAG_CONT_NAME}
podman start ${SWAG_CONT_NAME}