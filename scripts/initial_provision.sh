#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${SCRIPTS_ROOT}/.proj

cp ${SCRIPTS_ROOT}/scripts/image_acq.sh /home/${USER_NAME}/image_acq.sh
cp ${SCRIPTS_ROOT}/.proj /home/${USER_NAME}/.proj
chown ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/image_acq.sh  /home/${USER_NAME}/.proj
#chmod +x /home/${USER_NAME}/image_acq.sh
runuser --login ${USER_NAME} -c "SCRIPTS_ROOT=${SCRIPTS_ROOT} /bin/bash /home/${USER_NAME}/image_acq.sh"
wait $!
rm /home/${USER_NAME}/image_acq.sh /home/${USER_NAME}/.proj