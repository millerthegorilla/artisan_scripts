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
cp -a * /etc/systemd/system/

FILES=*
for f in ${FILES}
do
  echo -e "\n[Service]\nUser=${SYSTEMD_USER}" >> /etc/systemd/system/${f}
  if [[ -e /etc/systemd/system/${f} ]]
  then
      chcon -u system_u -t systemd_unit_file_t /etc/systemd/system/${f}
      systemctl enable ${f}
  fi
done
cd ${SCRIPTS_ROOT}
