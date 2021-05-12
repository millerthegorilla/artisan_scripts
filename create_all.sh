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

echo -e "Is this development ie debug? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) DEBUG="TRUE"; break;;
        No ) DEBUG="FALSE"; break;;
    esac
done

if [[ ${DEBUG} == "TRUE" ]]
then
    cp ./settings/settings_debug.py ./settings/settings.py 
else
    cp ./settings/settings_production.py ./settings/settings.py
fi

if [[ -f "./.proj" ]]
then
    source ./.proj
fi

if [[ -n "${PROJECT_NAME}" ]]
then
    echo "Project name is ${PROJECT_NAME}"
else
    echo "*** PROJECT NAME IS NOT SET ***"
fi

if [[ -z "${PROJECT_NAME}" ]]
then
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
DEBUG=${DEBUG}
CODE_PATH=${CODE_PATH}
PROJECT_NAME=${project_name}
SCRIPTS_ROOT=${PWD}
set +a

./scripts/get_variables.sh

set -a
source .env
set +a

echo SWAG_CONT_NAME=${SWAG_CONT_NAME} >> .archive
echo DJANGO_CONT_NAME=${DJANGO_CONT_NAME} >> .archive
echo CODE_PATH=${CODE_PATH} >> .archive

if [[ ${DEBUG} == "TRUE" ]]
then
   podman pod create --name ${POD_NAME} -p 127.0.0.1:8000:8000
else
   podman pod create --name ${POD_NAME} -p ${PORT1_DESCRIPTION} -p ${PORT2_DESCRIPTION} # --dns-search=${POD_NAME} --dns-opt=timeout:30 --dns-opt=attempts:5
fi

if [[ ${DEBUG} == "FALSE" ]]
then
   ./container_scripts/run_duckdns_cont.sh
fi

./container_scripts/run_clamd_cont.sh
./container_scripts/run_redis_cont.sh
./container_scripts/run_elastic_search_cont.sh
./container_scripts/run_maria_cont.sh

if [[ ${DEBUG} == "FALSE" ]]
then
   ./container_scripts/run_swag_cont.sh
fi

./container_scripts/run_django_cont.sh

## systemd generate files

echo -e "Generate and install systemd --user unit files? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) SYSD="TRUE"; break;;
        No ) SYSD="FALSE"; break;;
    esac
done

if [[ ${SYSD} == "TRUE" ]]
then
    cd ${SCRIPTS_ROOT}/systemd/   ## DIRECTORY CHANGE HERE

    podman generate systemd --files ${POD_NAME}
    set -a
     django_service=$(cat .django_container_id)
     django_cont_name=$DJANGO_CONT_NAME
    set +a

    ### TEMPLATE
    cat ${SCRIPTS_ROOT}/templates/gunicorn_start.service | envsubst > ${SCRIPTS_ROOT}/systemd/gunicorn_start.service 
    
    echo -e "You will need to run the script 'systemd_init.sh' as sudo user."
    # if [[ ! -e ${HOME}/.config/systemd/user ]]
    # then
    #     mkdir -p ${HOME}/.config/systemd/user
    # fi

    # cp -a * ${HOME}/.config/systemd/user/

    # FILES=*
    # for f in ${FILES}
    # do
    #   if [[ -e ${HOME}/.config/systemd/user/${f} ]]
    #   then
    #       chcon -t systemd_unit_file_t ${HOME}/.config/systemd/user/${f}
    #   fi
    # done

    # systemctl --user enable $(ls -p . | grep -v / | tr '\n' ' ')
fi

cd ${SCRIPTS_ROOT}   ## DIRECTORY CHANGE HERE

rm .env