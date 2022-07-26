#!/bin/bash
# this file is sourced by non root level container question.sh 
# to obtain root level question answers. 

# assume rootlevel 'general' questions have been asked and answered and import them for use
if ! [[ $(basename${1}) == "containers" ]]
then	
    source ${CONTAINER_SCRIPTS_ROOT}/settings.sh
fi

source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/local_settings.sh ${1}

echo local_settings ${2}