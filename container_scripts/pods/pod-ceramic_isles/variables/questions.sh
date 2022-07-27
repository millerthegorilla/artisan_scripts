#!/bin/bash

L_S_FILE=${1}

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

# # POD_NAME
# if [[ ${DEBUG} == "TRUE" && $(id -u ${USER_NAME}) -lt 1000 ]]
# then
#     echo -e "      ** warning **\n\nIt is not reccommended to use a service account when using debug mode.\n  If you wish to continue, use ./artisan_run.sh output to display the output from the runserver command.\nAlternatively, and better still (more secure), use a standard user account.\n"
# fi

echo -e "Enter your....\n"
read -p "Site name as used in the website header/logo : " site_name

pod_name=${PROJECT_NAME}_pod
read -p "Pod name [${pod_name}] : " POD_NAME
POD_NAME=${POD_NAME:-${pod_name}}

echo "POD_NAME=${POD_NAME}" >> ${L_S_FILE}

# PORT1_DESCRIPTION
PORT1_DESCRIPTION=0.0.0.0:443:443

echo "PORT1_DESCRIPTION=${PORT1_DESCRIPTION}" >> ${L_S_FILE}

# PORT2_DESCRIPTION
PORT2_DESCRIPTION=0.0.0.0:80:80

echo "PORT2_DESCRIPTION=${PORT2_DESCRIPTION}" >> ${L_S_FILE}