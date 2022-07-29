#!/bin/bash

${CONTAINER_SCRIPTS_ROOT}/systemd/templates.sh -r
${CONTAINER_SCRIPTS_ROOT}/systemd/generate_units.sh -r 
${CONTAINER_SCRIPTS_ROOT}/systemd/install_units.sh -r
