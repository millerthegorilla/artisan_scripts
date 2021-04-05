#!/bin/bash

echo -e "********* WARNING *********\n\nYou must have created the correct directory structure before running this script.  Run the script create_directories.sh as root first to create the directories, lower the ports open to rootless in sysctl and open the firewall ports.\n\nAlso, you must run the script initial_provision.sh, which will call this script when it has finished installing the podman images and building the django enabled image.  You can interrupt the script at any time and cleanup using the script cleanup.sh"

echo -e "Are the podman images installed (select a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

read -p "Enter your project name - this is used as a directory name, so must be conformant to bash requirements : " project_name

set -a
PROJECT_NAME=${project_name}
SCRIPTS_ROOT=${PWD}
set +a

./get_variables.sh

mv ./env_files/scripts_env ./.env

set -a
source .env
set +a

podman pod create --name $POD_NAME -p $PORT1_DESCRIPTION -p $PORT2_DESCRIPTION

./scripts/run_django_cont.sh
./scripts/run_duckdns_cont.sh
./scripts/run_clamd_cont.sh
./scripts/run_maria_cont.sh
./scripts/run_memcached_cont.sh
./scripts/run_elastic_search_cont.sh
./scripts/run_swag_cont.sh

rm .env
