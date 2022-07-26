#!/bin/bash

function check_settings_empty()
{
	echo debug 1 local_settings.sh {1} {2}
	if [[ -f ${1} ]]
	then
		if grep -q '[^[:space:]]' ${1};
		then
			echo -n "settings file contains data - moving it before creating new one"
			mv ${1} ${SCRIPTS_ROOT}/settings_files/partial_settings.old.${2}.$(date +%d-%m-%y_%T)
		else
			rm ${1}
		fi
	fi
	touch ${1}
}

function local_settings()
{   # check if absolute or relative path
	if [[ ${1} == /* ]]; then
	   LOCALS=${1}
	else
	   LOCALS=$(realpath $(dirname ${2}))/${1}
	fi
	path=$(basename "$(dirname "$(readlink -f ${1})")")/$(basename "$(readlink -f ${1})")
	path=${path//\//_}
	check_settings_empty ${LOCALS} ${path}
	echo ${LOCALS}
}