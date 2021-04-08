podman run -dit --pod=${POD_NAME} --name=${SWAG_CONT_NAME} --cap-add=NET_ADMIN -e PUID=1000 -e PGID=1000 -e TZ=Europe/London -e URL=${DUCKDNS_SUBDOMAIN}  -e VALIDATION=duckdns -e DUCKDNSTOKEN=${DUCKDNS_TOKEN} -e EXTRA_DOMAINS=${EXTRA_DOMAINS} -v ${SWAG_HOST_VOL_STATIC}:${SWAG_CONT_VOL_STATIC}:Z -v ${HOST_LOG_DIR}:${SWAG_CONT_LOG_DIR}:Z --restart unless-stopped ${SWAG_IMAGE}

cat ${SCRIPTS_ROOT}/templates/default | envsubst '${EXTRA_DOMAINS} ${DUCKDNS_SUBDOMAIN}' > ${SCRIPTS_ROOT}/swag/default

echo -e "Waiting for swag container to be ready.."
until podman exec -it swag_cont bash -c "ls /config/nginx/site-confs/default" &>/dev/null;
do
  echo -n "."
done

echo -e "\n"

podman cp ${SCRIPTS_ROOT}/swag/default ${SWAG_CONT_NAME}:/config/nginx/site-confs/default
podman cp ${SCRIPTS_ROOT}/swag/nginx ${SWAG_CONT_NAME}:/config/nginx/nginx.conf
podman exec -d ${SWAG_CONT_NAME} bash -c "chown abc:users /config/nginx/nginx.conf"
podman exec -d ${SWAG_CONT_NAME} bash -c "chown abc:users /config/nginx/site-confs/default"
podman exec -d ${SWAG_CONT_NAME} bash -c "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old"
podman exec -d ${SWAG_CONT_NAME} bash -c "ln -s /config/nginx/nginx.conf /etc/nginx/nginx.conf"

podman stop ${SWAG_CONT_NAME}
podman start ${SWAG_CONT_NAME}
