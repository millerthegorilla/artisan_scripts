#!/bin/bash

echo -e "********* WARNING *********\n\nYou must have created the correct directory structure before running this script.  Run the script create_directories.sh as root first to create the directories, lower the ports open to rootless in sysctl and open the firewall ports.\n\nAlso, you must run the script initial_provision.sh, which will call this script when it has finished installing the podman images and building the django enabled image.  You can interrupt the script at any time and cleanup using the script cleanup.sh"

echo -e "Are the directories created and the sysctl ports lowered (select a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) echo -e "\nOkay... run the script create_directories.sh as root, and then run initial_provision.sh as standard user to install the podman images and build the custom django image.  It will call this script when it finishes.\n" && exit 1;;
    esac
done

echo -e "Are the podman images installed (select a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) echo -e "\nOkay... run the script initial_provision.sh which will download the images and build the custom image, and which will then call this script.\n" && exit 1;;
    esac
done

if [[ -z "${PROJECT_NAME}" ]]
then
    if [[ -f "./.proj" ]]
    then
        source ./.proj
    fi
    
    if [[ -n "$PROJECT_NAME" ]]
    then
        echo "Project name is ${PROJECT_NAME}"
    else
        echo "*** PROJECT NAME IS NOT SET ***"
    fi
    
    read -p "Enter your project name - this is used as a directory name, so must be conformant to bash requirements [${PROJECT_NAME}] : " pn

    project_name=${pn:-${PROJECT_NAME}}
else
    project_name=$PROJECT_NAME
fi

if [[ -z "$CODE_PATH" ]]
then
    read -p 'Path to code (the django_artisan folder where manage.py resides) : ' CODE_PATH
else
    echo "CODE PATH is ${CODE_PATH}"
fi

set -a
CODE_PATH=${CODE_PATH}
PROJECT_NAME=${project_name}
SCRIPTS_ROOT=${PWD}
set +a

./get_variables.sh

set -a
source .env
set +a

echo SWAG_CONT_NAME=${SWAG_CONT_NAME} >> .archive
echo DJANGO_CONT_NAME=${DJANGO_CONT_NAME} >> .archive
podman pod create --name $POD_NAME -p $PORT1_DESCRIPTION -p $PORT2_DESCRIPTION

./scripts/run_maria_cont.sh
./scripts/run_duckdns_cont.sh
./scripts/run_clamd_cont.sh
./scripts/run_memcached_cont.sh
./scripts/run_elastic_search_cont.sh
./scripts/run_swag_cont.sh
./scripts/run_django_cont.sh

rm .env
