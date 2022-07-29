#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source ${CONTAINER_SCRIPTS_ROOT}/setup/setup.sh

SYSTEMD_UNIT_DIR="${CURRENT_DIR}/unit_files"

echo -e "Uninstall and remove systemd unit files? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) SYSD="TRUE"; break;;
        No ) SYSD="FALSE"; break;;
    esac
done

if [[ ${SYSD} == "TRUE" ]]
then
    pushd ${SYSTEMD_UNIT_DIR}

    FILES=*
    for f in ${FILES}
    do
      if [[ -e /etc/systemd/user/${f} ]]
      then
          systemctl disable ${f}
          rm -rf /etc/systemd/user/${f}
      fi
    done

    popd

    rm -rf ${SYSTEMD_UNIT_DIR}
fi