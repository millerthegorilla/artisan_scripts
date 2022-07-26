#!/bin/bash

function check_settings_empty()
{
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
	   local_settings=${1}
	else
	   local_settings=$(realpath $(dirname ${2}))/${1}
	fi
	path=$(basename "$(dirname "$(readlink -f ${1})")")/$(basename "$(readlink -f ${1})")
	path=${path//\//_}
	check_settings_empty ${local_settings} ${path}
	echo ${local_settings}
}