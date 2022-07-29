#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${PROJECT_SETTINGS}

runuser --login ${USER_NAME} -c "podman pod exists ${POD_NAME}"
retval=$?

if [[ ! $retval -eq 0 ]]
then
	echo no such pod!
else
        #chown swag_logs to be able to delete them
        # if [[ -z "${SWAG_CONT_NAME}" ]]
        # then
	       #  SN=swag_cont
        # else
        #     SN=${SWAG_CONT_NAME}
        # fi
        # runuser --login ${USER_NAME} -c "podman container exists ${SN}"
        # retval=$?
        # if  [[ retval -eq 0 ]]
        # then
        #     runuser --login ${USER_NAME} -c "podman exec -it ${SN} bash -c 'chown -R root:root /config/log'"
        # fi
    echo -e "\nshutting down and removing the pod..."
	runuser --login ${USER_NAME} -c "podman pod stop ${POD_NAME}"
	runuser --login ${USER_NAME} -c "podman pod rm ${POD_NAME}"
fi

# prune any miscellaneous images that may have been left over during builds.
runuser --login ${USER_NAME} -c "podman image prune -f"

runuser --login ${USER_NAME} -c "podman pod exists ${POD_NAME}"
if [[ $? != 0 ]]
then
    echo -n "Finished Cleaning."
else
    echo -n "Finished Cleaning but **pod still exists**"
fi 