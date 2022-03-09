#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -f ".archive" ]]; then
   set +a
   source .archive
   set -a
fi

if [[ -f ".proj" ]]; then
   set +a
   source .proj
   set -a
fi

if [[ ! -n "DEBUG" ]]
then
    echo -e "Is the project debug (choose a number) : "

    select yn in "Yes" "No"; do
        case $yn in
            Yes ) DEBUG="TRUE";;
            No ) DEBUG="FALSE";;
        esac
    done
fi

if [[ ! -n "$CODE_PATH" ]]
then
    until [[ -n "${CODE_PATH}" ]]
    do
        read -p "enter path to code (where manage.py resides) : " -e CODE_PATH
        if [[ -z "${CODE_PATH}" ]]
        then
            echo -e "the path to the code must be set to continue.  Try again or ctrl/c to quit."
        fi
    done 
fi

if [[ -z "$USER_NAME" ]]
then
    until [[ -n "${USER_NAME}" ]]
    do
        read -p "Enter the name of your standard/service user : " USER_NAME
        if [[ -z "${USER_NAME}" ]]
        then
            echo -e "the name of your user must be set to continue.  Try again or ctrl/c to quit."
        fi
    done
fi

if [[ -z ${POD_NAME} ]]
then
    read -p "Enter pod name: " POD_NAME
fi
if [[ -z ${PROJECT_NAME} ]]
then
    read -p "Enter project name: " PROJECT_NAME
fi

runuser --login ${USER_NAME} -c "podman pod exists ${POD_NAME}"
retval=$?

if [[ ! $retval -eq 0 ]]
then
	echo no such pod!
else
        #chown swag_logs to be able to delete them
        # if [[ -z "${SWAG_CONT_NAME}" ]]
        # then
	       #  SN=swag_cont
        # else
        #     SN=${SWAG_CONT_NAME}
        # fi
        # runuser --login ${USER_NAME} -c "podman container exists ${SN}"
        # retval=$?
        # if  [[ retval -eq 0 ]]
        # then
        #     runuser --login ${USER_NAME} -c "podman exec -it ${SN} bash -c 'chown -R root:root /config/log'"
        # fi
    echo -e "\nshutting down and removing the pod..."
	runuser --login ${USER_NAME} -c "podman pod stop ${POD_NAME}"
	runuser --login ${USER_NAME} -c "podman pod rm ${POD_NAME}"
fi

# prune any miscellaneous images that may have been left over during builds.
runuser --login ${USER_NAME} -c "podman image prune -f"

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
       unset CODE_PATH
    fi
fi

rm -r ${SCRIPTS_ROOT}/dockerfiles/django/*
rm ${SCRIPTS_ROOT}/dockerfiles/maria.sh
rm ${SCRIPTS_ROOT}/dockerfiles/dockerfile_django_dev
echo code path is ${CODE_PATH}

if [ -n ${CODE_PATH} ];
then
    find ${CODE_PATH} -type l -delete
fi

echo -e "remove all podman images (choose a number)?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) imgs_remove=1; break;;
        No ) imgs_remove=0; break;;
    esac
done

if [[ imgs_remove -eq 1 ]]
then
	runuser --login ${USER_NAME} -c "podman rmi python:latest swag:1.14.0 duckdns:latest redis:6.2.2-buster elasticsearch:7.11.2 docker-clamav:latest mariadb:latest"
fi

echo -e "save settings/.env to ./settings_env_old (choose a number)?"

select yn in "Yes" "No"; do
    case $yn in
        Yes ) save_sets=1; break;;
        No ) save_sets=0; break;;
    esac
done

if [[ save_sets -eq 1 ]]
then
    cp /etc/opt/${PROJECT_NAME}/settings/.env ./settings_env_old
fi

runuser --login ${USER_NAME} -c "podman volume rm ${DB_VOL_NAME}"
echo "swag vol name is ${SWAG_VOL_NAME}"
runuser --login ${USER_NAME} -c "podman volume rm ${SWAG_VOL_NAME}"
runuser --login ${USER_NAME} -c "podman volume prune -f"

rm .env
rm .archive
rm settings/settings.py
if [[ ${DEBUG} == "FALSE" ]]
then
    rm dockerfiles/swag/default
    rm settings/gunicorn.conf.py
fi

if [[ ${DEBUG} == "TRUE" ]]
then
    rm -rf /etc/opt/${PROJECT_NAME}/settings/*
    rm -rf /etc/opt/${PROJECT_NAME}/settings/.env
    rm -rf /etc/opt/${PROJECT_NAME}/static_files/*
else
    rm -rf /etc/opt/${PROJECT_NAME}/settings/* /etc/opt/${PROJECT_NAME}/settings/.env /etc/opt/${PROJECT_NAME}/static_files/*
fi

if [[ ${DEBUG} == "FALSE" ]]
then
    if [ -n ${CODE_PATH} ];
    then
        chown ${USER_NAME}:${USER_NAME} -R ${CODE_PATH}
        find ${CODE_PATH} -type f -exec chmod 0644 {} +
        find ${CODE_PATH} -type d -exec chmod 0755 {} +
    fi
    chown ${USER_NAME}:${USER_NAME} -R /etc/opt/${PROJECT_NAME}
    find /etc/opt/${PROJECT_NAME} -type f -exec chmod 0644 {} +
    find /etc/opt/${PROJECT_NAME} -type d -exec chmod 0755 {} +
fi

if [[ ! -n "$DJANGO_PROJECT_NAME" ]]
then
    if [ -n ${CODE_PATH} ];
    then
        PN=$(basename $(dirname $(find ${CODE_PATH} -name "asgi.py")))
    fi
    read -p "enter the name of the django project folder (where wsgi.py resides) [${PN}] : " -e DJANGO_PROJECT_NAME
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
        if [ -n ${CODE_PATH} ];
        then  
            rm -rf ${CODE_PATH}/media/cache
            rm -rf ${CODE_PATH}/media/uploads
        fi
    elif [[ -n ${DEBUG} && ${DEBUG} == "FALSE" ]]
    then
        rm -rf $/etc/opt/${PROJECT_NAME}/static/media/cache
        rm -rf $/etc/opt/${PROJECT_NAME}/static/media/uploads
    fi
fi

if [ -n ${CODE_PATH} ];
then
    if [[ ${DEBUG} == "TRUE" ]]
    then
        rm ${CODE_PATH}/manage.py
        rm ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py
    else
        rm -rf ${CODE_PATH}/manage.py ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py
    fi
fi

if [[ -n "${PROJECT_NAME}" ]]
then
    rm -rf /etc/opt/${PROJECT_NAME}
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
        if [[ -e ${USER_DIR}/${PROJECT_NAME} ]]
        then
            rm -rf ${USER_DIR}/${PROJECT_NAME}/logs
        fi
    else
        rm -rf ${USER_DIR}/${PROJECT_NAME}/logs
    fi
        
    if [[ -n "${PROJECT_NAME}" ]]
    then
        echo -e "remove ${USER_DIR}/${PROJECT_NAME} (choose a number)?"
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
                if [[ -e ${USER_DIR}/${PROJECT_NAME} ]]
                then
                    echo -e "removing swag logs"
                    rm -rf ${USER_DIR}/${PROJECT_NAME}
                fi
            else
                rm -rf ${USER_DIR}/${PROJECT_NAME}
            fi
        fi
    fi
}

if [[ logs_remove -eq 2 ]]
then
    mkdir ${SCRIPTS_ROOT}/old_logs
    mv ${USER_DIR}/${PROJECT_NAME}/logs/* ${SCRIPTS_ROOT}/old_logs/
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
    USER_NAME=${USER_NAME} SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_user_cleanup.sh
    cd ${SCRIPTS_ROOT}   
    rm -rf ${SCRIPTS_ROOT}/systemd 
    mkdir ${SCRIPTS_ROOT}/systemd
    cp ${SCRIPTS_ROOT}/templates/systemd/systemd_git_ignore ${SCRIPTS_ROOT}/systemd/.gitignore
    #chown ${USER_NAME}:${USER_NAME} ${SCRIPTS_ROOT}/systemd/.gitignore
fi

rm ${SCRIPTS_ROOT}/.proj