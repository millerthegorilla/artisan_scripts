#!/bin/bash

function get_tag()
{
	echo debug 1 get_tag custom_tag= ${CUSTOM_TAG}
	source ${1}/source.sh
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