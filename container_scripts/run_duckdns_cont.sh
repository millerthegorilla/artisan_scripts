#!/bin/bash
echo -e "run_duckdns_cont.sh"

source ${SCRIPTS_ROOT}/.env

if [[ -n ${DUCKDNS_SUBDOMAIN} ]]
then
    podman run -d --pod=${POD_NAME} --name=${DUCKDNS_CONT_NAME} -e SUBDOMAINS=${DUCKDNS_SUBDOMAIN} -e TZ="Europe/London" --secret=DUCKDNS_TOKEN,type=env --restart unless-stopped ${DUCKDNS_IMAGE}
else
	echo -e "DUCKDNS VARIABLES ARE NOT SET"
fi

