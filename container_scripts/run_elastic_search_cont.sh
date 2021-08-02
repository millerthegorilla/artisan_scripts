#!/bin/bash
echo -e "run_elastic_search_cont.sh"

source ${SCRIPTS_ROOT}/.env
source ${SCRIPTS_ROOT}/.proj

runuser --login ${USER_NAME} -c "${XDESK} podman run -dit --name=$ELASTIC_CONT_NAME --pod=$POD_NAME  -e discovery.type=\"single-node\" -e ES_JAVA_OPTS=\"-Xms512m -Xmx512m\" $ELASTIC_IMAGE &"
