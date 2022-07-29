#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

find ${SCRIPTS_ROOT} -type d -exec chmod 0550 -- {} +
find ${SCRIPTS_ROOT} -type f -exec chmod 0440 -- {} +
find ${SCRIPTS_ROOT}/container_scripts -type f -name "*$.sh" -exec chmod 0440 -- {} +
#find ${SCRIPTS_ROOT}/container_scripts -type f -name "settings.sh" -exec chmod 0640 -- {} +
find ${SCRIPTS_ROOT}/container_scripts -type d -exec chmod 0770 -- {} +
find ${SCRIPTS_ROOT}/scripts -type f -name "*$.sh" -exec chmod 0440 -- {} +
find ${SCRIPTS_ROOT}/.git -type d -exex chmod 0550 {} +
find ${SCRIPTS_ROOT}/.git/objects -type f -exec chmod 0444 -- {} +
find ${SCRIPTS_ROOT}/.git -type f | grep -v /objects/ | xargs chmod 640
find ${SCRIPTS_ROOT} -type d -exec chown ${SUDO_USER}:${SUDO_USER} -- {} +
find ${SCRIPTS_ROOT} -type f -exec chown ${SUDO_USER}:${SUDO_USER} -- {} +
find ${SCRIPTS_ROOT}/settings_files -type d -exec chown root:root -- {} + \
                                            -exec chmod 0660 -- {} +
find ${SCRIPTS_ROOT}/settings_files -type f -exec chown root:root -- {} + \
                                            -exec chmod 0440 -- {} +
chmod 0550 ${SCRIPTS_ROOT}/artisan_run.sh
chmod 0550 ${SCRIPTS_ROOT}/scripts

for install in $(find ${CONTAINER_SCRIPTS_ROOT} -type f -name "install$.sh" | sort)
do
    bash install -r
done

