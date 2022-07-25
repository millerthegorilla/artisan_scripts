#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -z "${SCRIPTS_ROOT}" ]]
then
    echo "Error!  SCRIPTS_ROOT must be defined"
    exit 1
fi

cd ${SCRIPTS_ROOT}/systemd

FILES=*
for f in ${FILES}
do
  if [[ -e /etc/systemd/system/${f} ]]
  then
      systemctl disable ${f}
      rm -rf /etc/systemd/system/${f}
  fi
done

cd ${SCRIPTS_ROOT}
