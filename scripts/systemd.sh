#!/bin/bash

${CONTAINER_SCRIPTS_ROOT}/systemd/templates.sh -r
${CONTAINER_SCRIPTS_ROOT}/systemd/generate.sh -r 
${CONTAINER_SCRIPTS_ROOT}/systemd/install.sh -r
