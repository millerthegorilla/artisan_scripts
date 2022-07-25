#!/bin/bash

# debug
echo DEBUG 1 setup.sh ${CONTAINER_SCRIPTS_ROOT}

echo DEBUG 2 setup.sh ${LOCAL_SETTINGS_FILE}
cat localsettingsfile contents ${LOCAL_SETTINGS_FILE}

source ${PROJECT_SETTINGS}

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