#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd ./systemd
cp -a * /etc/systemd/user/

FILES=*
for f in ${FILES}
do
  if [[ -e /etc/systemd/user/${f} ]]
  then
      chcon -t systemd_unit_file_t /etc/systemd/user/${f}
  fi
done

echo -e "now run the following command as the standard user, from within the systemd directory - systemctl --user enable $(ls -p . | grep -v / | tr '\n' ' ')"

cd ../