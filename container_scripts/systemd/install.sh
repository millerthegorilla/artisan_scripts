#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

SYSTEMD_UNIT_DIR="${CURRENT_DIR}/unit_files"

pushd ${SYSTEMD_UNIT_DIR}
cp -a * /etc/systemd/user/

FILES=*
for f in ${FILES}
do
  echo ${f} >> .gitignore
  if [[ -e /etc/systemd/user/${f} ]]
  then
      chcon -u system_u -t systemd_unit_file_t /etc/systemd/user/${f}
      runuser --login ${USER_NAME} -c "${XDESK} systemctl --user enable ${f}"
  fi
done

runuser --login ${USER_NAME} -c "${XDESK} systemctl --user daemon-reload"
popd
