#!/bin/bash

source ${SCRIPTS_ROOT}/.proj

runuser --login ${USER_NAME} -c "podman image exists python:latest"
if [[ ! $? -eq 0 ]]
then
	runuser --login ${USER_NAME} -c "podman pull docker.io/library/python:latest &"
fi

runuser --login ${USER_NAME} -c "podman image exists elasticsearch:7.11.2"
if [[ ! $? -eq 0 ]]
then
	runuser --login ${USER_NAME} -c "podman pull docker.io/library/elasticsearch:7.11.2 &"
fi

runuser --login ${USER_NAME} -c "podman image exists mariadb:10.5"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/library/mariadb:10.5 &"
fi

runuser --login ${USER_NAME} -c "podman image exists redis:6.2.2-buster"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/library/redis:6.2.2-buster &"
fi

runuser --login ${USER_NAME} -c "podman image exists docker-clamav:latest"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/mkodockx/docker-clamav:latest &"
fi

runuser --login ${USER_NAME} -c "podman image exists duckdns:latest"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/linuxserver/duckdns:latest &"
fi

runuser --login ${USER_NAME} -c "podman image exists swag:1.14.0"
if [[ ! $? -eq 0 ]]
then
    runuser --login ${USER_NAME} -c "podman pull docker.io/linuxserver/swag:version-1.14.0 &"
fi