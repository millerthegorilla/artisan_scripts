#!/bin/bash
# this file is sourced by non root level container question.sh 
# to obtain root level question answers. 

# assume rootlevel 'general' questions have been asked and answered and import them for use
# unless we are the rootlevel general questions
if ! [[ $(basename ${1}) == "containers" ]]
then	
    source ${CONTAINER_SCRIPTS_ROOT}/settings.sh
fi

# get and return correct local_settings file - either an absolute file path
# or an absolute file path with a relative path appended
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/local_settings.sh ${1}

echo $(local_settings ${2})

function get_tag()
{
	source ../image/source.sh
	if [[ -n "${CUSTOM_TAG}" ]];
	then
		tag=${CUSTOM_TAG}
	elif [[ -n "${TAG}" ]];
	then
		tag=${TAG}
	else
		echo -e "IMAGE TAG IS NOT SET!"
		exit 1
	fi

	if [[ ${DEBUG} == "TRUE" ]];
	then
		echo "${tag}_debug"
	else
		echo "${tag}_prod"
	fi
}