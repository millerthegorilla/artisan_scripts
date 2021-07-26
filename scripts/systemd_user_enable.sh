#!/bin/bash

cd ${SCRIPTS_ROOT}/systemd/
FILES=*
for f in ${FILES}
do
  if [[ -e /etc/systemd/user/${f} ]]
  then
      XDG_RUNTIME_DIR="/run/user/$(id -u)" DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus" systemctl --user enable ${f}
  fi
done

cd ${SCRIPTS_ROOT}   ## DIRECTORY CHANGE HERE