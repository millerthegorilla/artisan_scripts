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
# source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/local_settings.sh

# echo $(local_settings ${2} ${1})