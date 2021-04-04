#!/bin/bash

echo -e "********* WARNING *********\n\nYou must have created the correct directory structure before running this script.  Run the script create_directories.sh as root first to create the directories.\n\nAlso, you must run the script initial_provision.sh, which will call this script when it has finished installing the podman images.  And also, you must edit and complete the two files in the directory templates/env_files/ and save them in the directory ./env_files, before running this script.\n\nFinally, you must make sure that the host machine you are using has port 80 upwards open.  To do this manually, edit the /etc/sysctl.conf or /etc/sysctl.d/99-sysctl.conf or similar and include net.ipv4.ip_unprivileged_port_start=80 so that port 80 and 443 will open for connection to the nginx pod(swag).  Then reload sysctl using the command 'sudo systctl --system'.  Alternatively, the script create_directories.sh will do this for you."

echo -e "Are the podman images installed and have you completed the files in the directory templates/env_files/ and saved them in the ./env_files directory and have you edited syctl.conf and reloaded (select a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

read -p "Enter project name:" project_name
mv ./env_files/scripts_env ./.env

set -a
PROJECT_NAME=$project_name
source .env
set +a

mv ./env_files/settings_env /etc/opt/${PROJECT_NAME}/settings/.env

podman pod create --name $POD_NAME -p $PORT1_DESCRIPTION -p $PORT2_DESCRIPTION


./scripts/run_django_cont.sh
./scripts/run_duckdns_cont.sh
./scripts/run_clamd_cont.sh
./scripts/run_maria_cont.sh
./scripts/run_memcached_cont.sh
./scripts/run_elastic_search_cont.sh
./scripts/run_swag_cont.sh

rm .env
