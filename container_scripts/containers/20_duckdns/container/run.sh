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

if [[ -n ${DUCKDNS_DOMAIN} && -n ${DUCKDNS_CONT_NAME} && -n ${DUCKDNS_IMAGE} ]]
then
    runuser --login ${USER_NAME} -c "podman run -d --pod=${POD_NAME} ${AUTO_UPDATES} --name=${DUCKDNS_CONT_NAME} -e SUBDOMAINS=${DUCKDNS_DOMAIN} -e TZ=\"Europe/London\" --secret=DUCKDNS_TOKEN,type=env,target=TOKEN ${DUCKDNS_IMAGE}"
else
	echo -e "DUCKDNS VARIABLES ARE NOT SET"
fi