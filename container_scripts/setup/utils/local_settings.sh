#!/bin/bash

function local_settings()
{   # check if absolute or relative path
	if [[ ${1} == /* ]]; then
	   echo ${1}
	else
	  echo $(realpath ${0})/${1}
	fi
}