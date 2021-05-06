#!/bin/bash

podman run -dit --pod ${POD_NAME} --name ${REDIS_CONT_NAME} ${REDIS_IMAGE}
