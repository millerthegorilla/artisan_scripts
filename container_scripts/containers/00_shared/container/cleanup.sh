#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

# REMOVE CODE?
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

# SAVE AND REMOVE SETTINGS ENV FILE
echo -e "save settings/.env (choose a number)?"

select yn in "Yes" "No"; do
    case $yn in
        Yes ) save_sets=1; break;;
        No ) save_sets=0; break;;
    esac
done

if [[ save_sets -eq 1 ]]
then
    cp /etc/opt/${PROJECT_NAME}/settings/.env ${SCRIPTS_ROOT}/settings_files/env_files/env-${PROJECT_NAME}.$(date +%d-%m-%y_%T)
fi

# REMOVE SAVED SETTINGS FILE
if [[ -e ${CONTAINER_SCRIPTS_ROOT}/settings/setting.py ]];
then
    rm ${CONTAINER_SCRIPTS_ROOT}/settings/settings.py
fi

# REMOVE DIRECTORIES AND FILE[S UNDER /etc/opt
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
    rm -rf /etc/opt/${PROJECT_NAME}
else
    rm -rf /etc/opt/${PROJECT_NAME}/settings/*
    rm -rf /etc/opt/${PROJECT_NAME}/settings/.env
    rm -rf /etc/opt/${PROJECT_NAME}/static_files/*
    find ${CODE_PATH} -maxdepth 1 -empty -type d -perm -1000 | xargs -r rmdir
    rm -rf /etc/opt/${PROJECT_NAME}
fi

# REMOVE LOGS
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