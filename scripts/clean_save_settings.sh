#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

echo -e "Do you want to save your local partial settings first before you clear them [ No ] ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) SAVE="TRUE"; break;;
        No ) SAVE="FALSE"; break;;
		* ) SAVE="FALSE"; break;;
    esac
done

if [[ SAVE == "TRUE" ]];
then
	FILEPATH=${SCRIPTS_ROOT}/settings_files/project_settings.${PROJECT_NAME}.$(date +%d-%m-%y_%T)
	for file in $(find ${CONTAINER_SCRIPTS_ROOT}/containers -type f -name "settings.sh" | sort)
	do
		cat ${file} > ${FILEPATH}
	    rm ${file}
	    touch ${file}
	    chmod 0600 ${file}
	done
fi