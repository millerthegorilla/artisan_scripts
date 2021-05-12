#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd ./systemd
if [[ $(ls | wc -l) != 0 ]]
then
    systemctl --user disable $(ls -p . | grep -v / | tr '\n' ' ')
fi

FILES=*
for f in ${FILES}
do
  if [[ -e /etc/systemd/user/${f} ]]
  then
      rm -rf /etc/systemd/user/${f}
  fi
done

cd ../
rm -rf ./systemd 
mkdir systemd
touch ./systemd/.gitignore