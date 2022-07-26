#!/bin/bash

source ${SCRIPTS_ROOT}/.proj

cd ${SCRIPTS_ROOT}/systemd/
FILES=*
for f in ${FILES}
do
  if [[ -e /etc/systemd/user/${f} ]]
  then
      runuser --login ${USER_NAME} -c "${XDESK} systemctl --user enable ${f}"
  fi
done

runuser --login ${USER_NAME} -c "${XDESK} systemctl --user daemon-reload"

cd ${SCRIPTS_ROOT}   ## DIRECTORY CHANGE HERE