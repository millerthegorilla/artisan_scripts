#!/bin/bash

podman run -dit --name=$ELASTIC_CONT_NAME --pod=$POD_NAME  -e discovery.type="single-node" -e ES_JAVA_OPTS="-Xms256m -Xmx256m" $ELASTIC_IMAGE
