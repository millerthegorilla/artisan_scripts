#!/bin/bash
podman image exists python:latest
if [[ ! $? -eq 0 ]]
then
   echo -e "Yeah baby, yeah!"
fi
