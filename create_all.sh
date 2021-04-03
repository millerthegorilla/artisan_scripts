#!/bin/bash

echo -e "********* WARNING *********\n\nYou must have created the correct directory structure before running this script.  Run the script create_directories.sh as root first to create the directories.\n\n Also, you must edit and complete the two files in the directory env_files, before running this script.\n"

echo Have you completed the files in the directory env_files (select a number)?
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done


cp ./env_files/scripts_env ./.env

set -a
source .env
set +a

cp ./env_files/settings_env /etc/opt/${PROJECT_NAME}/settings/.env

podman pod create --name $POD_NAME -p $PORT1_DESCRIPTION -p $PORT2_DESCRIPTION

#./run_django_cont.sh
#./run_duckdns_cont.sh
#./run_clamd_cont.sh
./run_maria_cont.sh
#./run_memcached_cont.sh
#./run_elastic_search_cont.sh
#./run_swag_cont.sh
