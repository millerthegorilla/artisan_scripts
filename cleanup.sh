#!/bin/bash

if [[ -f ".archive" ]]; then
   set +a
   source .archive
   set -a
else
   read -p "Enter pod name: " POD_NAME
   read -p "Enter project name " PROJECT_NAME
fi

echo -e "save settings_env to ./settings_env_old (choose a number)?"

select yn in "Yes" "No"; do
    case $yn in
        Yes ) save_sets=1; break;;
        No )  save_sets=0; break;;
    esac
done

if [[ save_sets -eq 1 ]]
then
        cp /etc/opt/${PROJECT_NAME}/settings/.env ./settings_env_old
fi

rm -rf /etc/opt/${PROJECT_NAME}/settings/*
rm -rf /etc/opt/${PROJECT_NAME}/static_files/*

podman pod exists ${POD_NAME};
retval=$?

if [[ ! $retval -eq 0 ]]
then
	echo no such pod!
else
	podman pod stop ${POD_NAME}
	podman pod rm ${POD_NAME}
fi

echo -e "remove code (choose a number)?"

select yn in "Yes" "No"; do
    case $yn in
        Yes ) code_remove=1; break;;
        No ) code_remove=0; break;;
    esac
done

if [[ code_remove -eq 1 ]]
then
	rm -rf /opt/${PROJECT_NAME}/*
fi

echo -e "remove podman images (choose a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) imgs_remove=1; break;;
        No ) imgs_remove=0; break;;
    esac
done

if [[ imgs_remove -eq 1 ]]
then
        podman rmi python:django
	podman rmi python:latest
	podman rmi swag:latest
        podman rmi duckdns:latest
	podman rmi memcached:latest
	podman rmi elasticsearch:7.11.2
	podman rmi docker-clamav:latest
	podman rmi mariadb:latest
fi

rm .env
rm swag/default
rm settings/gunicorn.conf.py

echo -e "remove logs or save logs and remove logs dir (choose a number)?"
select yn in "Yes" "No" "Save"; do
    case $yn in
        Yes ) logs_remove=1; break;;
        No ) logs_remove=0; break;;
        Save ) logs_remove=2; break;;
    esac
done

if [[ logs_remove -eq 2 ]]
then
    if [[ -z "$LOG_DIR" ]]
    then
    	read -p "absolute path to logs dir : " LOG_DIR
    fi        	
    mkdir old_logs
    mv ${LOG_DIR}/* old_logs
    rm -rf ${LOG_DIR}
fi

if [[ logs_remove -eq 1 ]]
then
    if [[ -z "$LOG_DIR" ]]
    then
        read -p "absolute path to logs dir : " LOG_DIR
    fi 
    rm -rf ${LOG_DIR}
fi

rm .archive

echo -e "You will need to remove the following directories as sudo user"
echo -e "/opt/${PROJECT_NAME} && /etc/opt/${PROJECT_NAME}" 
