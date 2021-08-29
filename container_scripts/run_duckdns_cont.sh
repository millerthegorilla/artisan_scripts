#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "run_duckdns_cont.sh"

source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.proj

if [[ -n ${DUCKDNS_SUBDOMAIN} ]]
then
    runuser --login ${USER_NAME} -c "podman run -d --pod=${POD_NAME} ${UPDATES} --name=${DUCKDNS_CONT_NAME} -e SUBDOMAINS=${DUCKDNS_SUBDOMAIN} -e TZ=\"Europe/London\" --secret=DUCKDNSTOKEN,type=env --restart unless-stopped ${DUCKDNS_IMAGE}"
else
	echo -e "DUCKDNS VARIABLES ARE NOT SET"
fi

