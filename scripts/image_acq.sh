#!/bin/bash

source .proj

podman image exists python:latest
if [[ ! $? -eq 0 ]]
then
	podman pull docker.io/library/python:latest &
fi

podman image exists elasticsearch:7.11.2
if [[ ! $? -eq 0 ]]
then
	podman pull docker.io/library/elasticsearch:7.11.2 &
fi

podman image exists mariadb:10.5
if [[ ! $? -eq 0 ]]
then
    podman pull docker.io/library/mariadb:10.5 &
fi

podman image exists redis:6.2.2-buster
if [[ ! $? -eq 0 ]]
then
    podman pull docker.io/library/redis:6.2.2-buster &
fi

podman image exists docker-clamav:latest
if [[ ! $? -eq 0 ]]
then
    podman pull docker.io/mkodockx/docker-clamav:latest &
fi

podman image exists duckdns:latest
if [[ ! $? -eq 0 ]]
then
    podman pull docker.io/linuxserver/duckdns:latest &
fi

podman image exists swag:1.14.0
if [[ ! $? -eq 0 ]]
then
    podman pull docker.io/linuxserver/swag:version-1.14.0 &
fi

wait