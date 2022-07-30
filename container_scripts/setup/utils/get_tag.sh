#!/bin/bash

function get_tag()
{
	source ${1}/../image/source.sh
	if [[ -n "${CUSTOM_TAG}" ]];
	then
		tag=${CUSTOM_TAG}
	elif [[ -n "${TAG}" ]];
	then
		tag=${TAG}
	else
		echo -e "IMAGE TAG IS NOT SET! - $(basename ${1})"
		exit 1
	fi

	if [[ ${DEBUG} == "TRUE" ]];
	then
		echo "${tag}_debug"
	else
		echo "${tag}_prod"
	fi
}