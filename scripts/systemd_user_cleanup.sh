#!/bin/bash

if [[ -e ${SCRIPTS_ROOT}/.proj ]]
then
    source ${SCRIPTS_ROOT}/.proj
else
    read -p "Enter username : " USER_NAME
    XDESK="XDG_RUNTIME_DIR=\"/run/user/$(id -u ${USER_NAME})\" DBUS_SESSION_BUS_ADDRESS=\"unix:path=${XDG_RUNTIME_DIR}/bus\""
fi

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
  if [[ -e /etc/systemd/user/${f} ]]
  then
  	  runuser --login ${USER_NAME} -c "${XDESK} systemctl --user disable ${f}"
  	  if [[ ! $? -eq 0 ]]
  	  then
  	  	  echo -e "\nFailed whilst disabling systemd units."
  	  	  exit 1
  	  fi
      rm -rf /etc/systemd/user/${f}
  fi
done

cd ${SCRIPTS_ROOT}
