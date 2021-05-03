#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cp -aZ ./systemd/* /etc/systemd/system/

systemctl enable --now $(ls -p ./systemd | grep -v / | tr '\n' ' ')

