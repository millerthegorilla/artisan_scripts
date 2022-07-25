#!/bin/bash
# this file is sourced by non root level container question.sh 
# to obtain root level question answers. 

# assume rootlevel 'general' questions have been asked and answered and import them for use
source ${CONTAINER_SCRIPTS_ROOT}/settings.sh

if [[ -f ${LOCAL_SETTINGS_FILE} ]]
then
	if grep -q '[^[:space:]]' ${LOCAL_SETTINGS_FILE};
	then
		echo -n "settings file contains data - moving it before creating new one"
		mv ${LOCAL_SETTINGS_FILE} ./settings.old.$(date +%d-%m-%y_%T)
	else
		rm ${LOCAL_SETTINGS_FILE}
	fi
fi
touch ${LOCAL_SETTINGS_FILE}