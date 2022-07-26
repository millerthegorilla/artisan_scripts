#!/bin/bash

EXT=${1}

function local_settings()
{   # check if absolute or relative path
	if [[ ${1} == /* ]]; then
	   echo ${1}
	else
	  echo $(realpath ${EXT})/${1}
	fi
}