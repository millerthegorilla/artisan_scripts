#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

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

# if [ -n ${CODE_PATH} ];
# then
#     find ${CODE_PATH} -type l -delete
# fi

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