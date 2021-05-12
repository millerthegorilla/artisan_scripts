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

echo -e "save settings/.env to ./settings_env_old (choose a number)?"

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

podman pod exists ${POD_NAME};
retval=$?

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

rm -rf /etc/opt/${PROJECT_NAME}/settings/*
rm -rf /etc/opt/${PROJECT_NAME}/settings/.env
rm -rf /etc/opt/${PROJECT_NAME}/static_files/*

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
rm settings/settings.py
rm settings/settings_env
rm settings/supervisor_gunicorn

if [[ ! -n "$CODE_PATH" ]]
then
    read -p "enter path to code (where manage.py resides) : " CODE_PATH
fi
if [[ ! -n "$DJANGO_PROJECT_NAME" ]]
then
    read -p "enter the name of the django project folder (where wsgi.py resides) : " DJANGO_PROJECT_NAME
fi

rm ${CODE_PATH}/manage.py
rm ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py

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
    if [[ -n "$LOG_DIR" ]]
    then
        if [[ -n "${PROJECT_NAME}" ]]
        then
            pname="[${HOME}/${PROJECT_NAME}/logs]"
        fi
    	read -p "absolute path to logs dir ${pname}: " ldir
    fi
    LOG_DIR=${ldir:-${pname}}
    mkdir old_logs
    mv ${LOG_DIR}/* old_logs
    rm -rf ${LOG_DIR}
    if [[ -n "$PROJECT_NAME" ]]
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
            rm -rf ${HOME}/${PROJECT_NAME}
        fi
     fi
fi

if [[ logs_remove -eq 1 ]]
then
    if [[ -n "$LOG_DIR" ]]
    then
        if [[ -n "${PROJECT_NAME}" ]]
        then
            pname="[${HOME}/${PROJECT_NAME}/logs]"
        fi
        read -p "absolute path to logs dir ${pname} : " ldir
        LOG_DIR=${ldir:-${pname}}
    fi 
    rm -rf ${LOG_DIR}
    if [[ -n "$PROJECT_NAME" ]]
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
            rm -rf ${HOME}/${PROJECT_NAME}
        fi
     fi
fi

# echo -e "Uninstall and remove systemd --user unit files? : "
# select yn in "Yes" "No"; do
#     case $yn in
#         Yes ) SYSD="TRUE"; break;;
#         No ) SYSD="FALSE"; break;;
#     esac
# done

# if [[ ${SYSD} == "TRUE" ]]
# then
#     cd ./systemd
#     if [[ $(ls | wc -l) != 0 ]]
#     then
#         systemctl --user disable $(ls -p . | grep -v / | tr '\n' ' ')
#     fi

#     FILES=*
#     for f in ${FILES}
#     do
#       if [[ -e ${HOME}/.config/systemd/user/${f} ]]
#       then
#           rm -rf ${HOME}/.config/systemd/user/${f}
#       fi
#     done

#     cd ../
#     rm -rf ./systemd 
#     mkdir systemd
#     touch ./systemd/.gitignore
# fi


echo -e "You will need to remove the following directory as sudo user:"
echo -e "/etc/opt/${PROJECT_NAME}."
echo -e "\nand run the script 'systemd_cleanup.sh' as sudo user."
if [[ -n ${DEBUG} && ${DEBUG}=="FAlSE" ]]
then
    if [[ -e ${HOME}/${PROJECT_NAME} ]]
    then
        echo -e "{HOME}/${PROJECT_NAME}/"
    fi
fi

if [[ -f "./.archive" ]]
then
    rm ./.archive
fi

if [[ -f "./.proj" ]]
then
    rm ./.proj
fi