#!/bin/bash

function get_tag()
{
	source ${1}/../image/source.sh
	if [[ -n "${CUSTOM_TAG}" ]];
	then
		tag=${CUSTOM_TAG}
		if [[ ${DEBUG} == "TRUE" ]];
		then
			tag="${tag}_debug"
		else
			tag="${tag}_prod"
		fi
	elif [[ -n "${TAG}" ]];
	then
		tag=${TAG}
	else
		echo -e "IMAGE TAG IS NOT SET! - $(basename ${1})"
		exit 1
	fi

	echo "${tag}"
}