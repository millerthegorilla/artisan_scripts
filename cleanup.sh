#!/bin/bash
read -p "Enter pod name: " pod_name
read -p "Enter project name " project_name

echo -e "save settings_env (choose a number)?"

select yn in "Yes" "No"; do
    case $yn in
        Yes ) save_sets=1; break;;
        No )  save_sets=0; break;;
    esac
done

if [[ save_sets -eq 1 ]]
then
        cp /etc/opt/${project_name}/settings/.env ./env_files/settings_env
fi

podman pod exists ${pod_name};
retval=$?

if [[ ! $retval -eq 0 ]]
then
	echo no such pod!
else
	podman pod stop ${pod_name}
	podman pod rm ${pod_name}
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
	rm -rf /opt/${project_name}/*
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

rm swag/default
rm settings/gunicorn.conf.py

echo -e "You will need to remove the following directories as sudo user"
echo -e "/opt/${project_name} && /etc/opt/${project_name}" 
