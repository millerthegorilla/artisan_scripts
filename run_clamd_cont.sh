#!/bin/bash

podman run -dit --pod ${POD_NAME} --name ${CLAM_CONT_NAME} ${CLAM_IMAGE}

