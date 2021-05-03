#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

systemctl disable --now $(ls -p ./systemd | grep -v / | tr '\n' ' ')

FILES=./systemd/*
for f in $FILES
do
  if [[ -e /etc/systemd/system/$f ]]
  then
      rm /etc/systemd/system/$f
  fi
done