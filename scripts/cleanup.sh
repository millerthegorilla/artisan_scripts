#!/bin/bash

if [[ -f ".archive" ]]; then
   set +a
   source .archive
   set -a
fi

if [[ -z ${POD_NAME} ]]
then
    read -p "Enter pod name: " POD_NAME
fi
if [[ -z ${PROJECT_NAME} ]]
then
    read -p "Enter project name " PROJECT_NAME
fi

podman pod exists ${POD_NAME};
retval=$?

if [[ ! $retval -eq 0 ]]
then
	echo no such pod!
else
        #chown swag_logs to be able to delete them
        if [[ -z "${SWAG_CONT_NAME}" ]]
        then
	    SN=swag_cont
        else
            SN=${SWAG_CONT_NAME}
        fi
        podman container exists ${SN}
        retval=$?
        if  [[ retval -eq 0 ]]
        then
            podman exec -it ${SN} bash -c "chown -R root:root /config/log"
        fi
        echo -e "\nshutting down and removing the pod..."
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
    echo -e "**** WARNING ****\n"
    echo -e "This will irretrievably remove your django code.\n"
    echo -e "Make sure you have run git commit!\n"
    echo -e "Are you certain you want to remove code??"

    select yn in "Yes" "No"; do
        case $yn in
            Yes ) code_remove=1; break;;
            No ) code_remove=0; break;;
        esac
    done
    if [[ code_remove -eq 1 ]]
    then
	   rm -rf ${CODE_PATH}
    fi
fi


## TODO check for image existence before deleting
if [[ ${DEBUG} == "TRUE" ]]
then
    podman rmi python:artisan_debug
else
    podman rmi python:artisan_prod
    podman rmi swag:artisan
fi

rm -rf ${SCRIPTS_ROOT}/dockerfiles/django/*

echo -e "remove all podman images (choose a number)?"
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

echo -e "save settings/.env to ./settings_env_old (choose a number)?"

select yn in "Yes" "No"; do
    case $yn in
        Yes ) save_sets=1; break;;
        No )  save_sets=0; break;;
    esac
done

source ${SCRIPTS_ROOT}/scripts/super_access.sh

if [[ save_sets -eq 1 ]]
then
        super_access "cp /etc/opt/${PROJECT_NAME}/settings/.env ./settings_env_old"
fi

rm .env
rm .archive
rm .proj
rm dockerfiles/swag/default
rm settings/gunicorn.conf.py
rm settings/settings.py
rm settings/settings_env
rm settings/supervisor_gunicorn
rm -rf /etc/opt/${PROJECT_NAME}/settings/*
rm -rf /etc/opt/${PROJECT_NAME}/settings/.env
rm -rf /etc/opt/${PROJECT_NAME}/static_files/*

if [[ ! -n "$CODE_PATH" ]]
then
    read -p "enter path to code (where manage.py resides) : " CODE_PATH
fi

if [[ ! -n "$DJANGO_PROJECT_NAME" ]]
then
    PN=$(basename $(dirname $(find ${CODE_PATH} -name "asgi.py")))
    read -p "enter the name of the django project folder (where wsgi.py resides) [${PN}] : " DJANGO_PROJECT_NAME
    DJANGO_PROJECT_NAME=${DJANGO_PROJECT_NAME:-${PN}}
fi

echo -e "remove media files (choose a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) mediafiles_remove=1; break;;
        No ) mediafiles_remove=0; break;;
    esac
done

if [[ ${mediafiles_remove} == 1 ]]
then
    if [[ -n ${DEBUG} && ${DEBUG} == "TRUE" ]]
    then   
        rm -rf ${CODE_PATH}/media/cache
        rm -rf ${CODE_PATH}/media/uploads
    elif [[ -n ${DEBUG} && ${DEBUG} == "FALSE" ]]
    then
        rm -rf $/etc/opt/${PROJECT_NAME}/static/media/cache
        rm -rf $/etc/opt/${PROJECT_NAME}/static/media/uploads
    fi
fi

rm ${CODE_PATH}/manage.py
rm ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py

if [[ -n "${PROJECT_NAME}" ]]
then
    super_access "rm -rf /etc/opt/${PROJECT_NAME}"
fi

echo -e "remove logs or save logs and remove logs dir (choose a number)?"
select yn in "Yes" "No" "Save"; do
    case $yn in
        Yes ) logs_remove=1; break;;
        No ) logs_remove=0; break;;
        Save ) logs_remove=2; break;;
    esac
done

remove_logs_dir()
{
    if [[ -n ${DEBUG} && ${DEBUG} == "FALSE" ]]
    then
        if [[ -e ${HOME}/${PROJECT_NAME} ]]
        then
            echo -e "removing swag logs - enter your sudo user password..."
            super_access "rm -rf ${HOME}/${PROJECT_NAME}/logs"
        fi
    else
        rm -rf ${HOME}/${PROJECT_NAME}/logs
    fi
        
    if [[ -n "${PROJECT_NAME}" ]]
    then
        echo -e "remove ${HOME}/${PROJECT_NAME} (choose a number)?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) remove_home=1; break;;
                No ) remove_home=0; break;;
            esac
        done
        if [[ remove_home==1 ]]
        then
            if [[ -n ${DEBUG} && ${DEBUG} == "FAlSE" ]]
            then
                if [[ -e ${HOME}/${PROJECT_NAME} ]]
                then
                    echo -e "removing swag logs"
                    super_access "rm -rf ${HOME}/${PROJECT_NAME}"
                fi
            else
                rm -rf ${HOME}/${PROJECT_NAME}
            fi
        fi
    fi
}

if [[ logs_remove -eq 2 ]]
then
    mkdir ${SCRIPTS_ROOT}/old_logs
    mv ${HOME}/${PROJECT_NAME}/logs/* ${SCRIPTS_ROOT}/old_logs/
    remove_logs_dir
fi

if [[ logs_remove -eq 1 ]]
then
    remove_logs_dir
fi

echo -e "Uninstall and remove systemd unit files? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) SYSD="TRUE"; break;;
        No ) SYSD="FALSE"; break;;
    esac
done

if [[ ${SYSD} == "TRUE" ]]
then
    cd ${SCRIPTS_ROOT}/systemd
    if [[ ${DEBUG} == "TRUE" ]]
    then
        FILES=*
        for f in ${FILES}
        do
          if [[ -e /etc/systemd/user/${f} ]]
          then
            systemctl --user disable ${f}
          fi
        done
        super_access "SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_user_cleanup.sh"
    else
        super_access "SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_cleanup.sh"
    fi
    cd ${SCRIPTS_ROOT}   
    rm -rf ${SCRIPTS_ROOT}/systemd 
    mkdir ${SCRIPTS_ROOT}/systemd
    cp ${SCRIPTS_ROOT}/templates/systemd/systemd_git_ignore ${SCRIPTS_ROOT}/systemd/.gitignore
fi