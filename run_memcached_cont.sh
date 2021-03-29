#!/bin/bash

podman run -dit --pod $POD_NAME --name $MEMCACHED_NAME $MEMCACHED_IMAGE
