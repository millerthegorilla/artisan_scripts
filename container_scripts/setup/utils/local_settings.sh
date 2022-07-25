#!/bin/bash

EXT=${1}

function local_settings()
{
	if [[ ${1} == /* ]]; then
	      echo ${1}
	   else
	      echo $(dirname $(realpath ${EXT}))/${1}
	   fi
}