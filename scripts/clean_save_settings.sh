#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

echo -e "Do you want to save settings first before you clear them? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) SAVE="TRUE"; break;;
        No ) SAVE="FALSE"; break;;
    esac
done

FILES=${find ${CONTAINER_SCRIPTS_ROOT}/containers -type f -name "settings.sh" | sort}

if [[ SAVE == "TRUE" ]];
then
	FILEPATH=${SCRIPTS_ROOT}/settings_files/project_settings.${PROJECT_NAME}.$(date +%d-%m-%y_%T)
	touch FILEPATH
	for file in ${FILES}
	do
		cat ${file} >> ${FILEPATH}
	done
fi

for file in ${FILES}
do
	FILEPATH=$(dirname ${file})
	rm ${file}
	touch ${FILEPATH}/settings.sh
	chmod 0600 ${FILEPATH}/settings.sh
done