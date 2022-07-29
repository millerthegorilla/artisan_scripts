#!/bin/bash

find ${SCRIPTS_ROOT} -type d | xargs chmod 0550
find ${SCRIPTS_ROOT} -type f | xargs chmod 0440
find ${SCRIPTS_ROOT}/container_scripts -type f -name "*$.sh" | xargs chmod 0550
find ${SCRIPTS_ROOT}/container_scripts -type f -name "settings.sh" | xargs chmod 0660
find ${SCRIPTS_ROOT}/container_scripts -type d | xargs chmod 0770
find ${SCRIPTS_ROOT}/scripts -type f -name "*$.sh" | xargs chmod 0440
find ${SCRIPTS_ROOT}/git -type d | xargs chmod 0550
find ${SCRIPTS_ROOT}/git/objects -type f | xargs chmod 444
find ${SCRIPTS_ROOT}/git -type f | grep -v /objects/ | xargs chmod 640
find ${SCRIPTS_ROOT} -type d | xargs chown ${SUDO_USER}:${SUDO_USER}
find ${SCRIPTS_ROOT} -type f | xargs chown ${SUDO_USER}:${SUDO_USER}
find ${SCRIPTS_ROOT}/settings_files -type d -exec chown root:root -- {} + \
                                            -exec chmod 0660 -- {} +
find ${SCRIPTS_ROOT}/settings_files -type f | xargs chown root:root | xargs chmod 0440
chmod 0550 ${SCRIPTS_ROOT}/artisan_run.sh

for install in $(find ${CONTAINER_SCRIPTS_ROOT} -type f -name "install$.sh" | sort)
do
    bash install -r
done

