#!/bin/bash

EXT=$(dirname ${1})
path=$(basename "$(dirname "$(readlink -f ${1})")")/$(basename "$(readlink -f ${1})")
path=${path//\//_}

function check_settings()
{
	if [[ -f ${1} ]]
	then
		if grep -q '[^[:space:]]' ${1};
		then
			echo -n "settings file contains data - moving it before creating new one"
			mv ${1} ${SCRIPTS_ROOT}/settings_files/partial_settings.old.${path}.$(date +%d-%m-%y_%T)
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
	   LOCALS=$(realpath ${EXT})/${1}
	fi
	check_settings ${LOCALS}
	echo ${LOCALS}
}