#!/bin/bash

podman run -d --pod=$POD_NAME --name=$DUCKDNS_CONT_NAME -e SUBDOMAINS=$DUCKDNS_SUBDOMAIN -e TZ=Europe/London -e TOKEN=$DUCKDNS_TOKEN --restart unless-stopped $DUCKDNS_IMAGE

