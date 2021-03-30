podman run -dit --pod=$POD_NAME --name=$SWAG_CONT_NAME --cap-add=NET_ADMIN -e PUID=1000 -e PGID=1000 -e TZ=Europe/London -e URL=$URL  -e VALIDATION=duckdns -e DUCKDNSTOKEN=$DUCKDNS_TOKEN -e EXTRA_DOMAINS=ceramicisles.org --restart unless-stopped $SWAG_IMAGE
podman cp swag/default swag_cont:/config/nginx/site-confs/default
podman cp swag/nginx swag_cont:/config/nginx/nginx.conf
podman exec -d swag_cont bash -c "chown abc:users /config/nginx/nginx.conf"
podman exec -d swag_cont bash -c "chown abc:users /config/nginx/site-confs/default"
#podman exec -d swag_cont bash -c "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old"
#podman exec -d swag_cont bash -c "ln -s /config/nginx/nginx.conf /etc/nginx/nginx.conf"
