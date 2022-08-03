#!/bin/bash

bash ${CONTAINER_SCRIPTS_ROOT}/systemd/templates.sh
bash ${CONTAINER_SCRIPTS_ROOT}/systemd/generate_units.sh 
bash ${CONTAINER_SCRIPTS_ROOT}/systemd/install_units.sh
