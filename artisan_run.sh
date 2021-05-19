#!/bin/bash

PARAMS=""

set -a
SCRIPTS_ROOT=$(pwd)
source ${SCRIPTS_ROOT}/options
set +a

while (( "$#" )); do
  case "$1" in
    create)
      ${SCRIPTS_ROOT}/scripts/initial_provision.sh  
      exit $? 
      ;;
    clean)
      ${SCRIPTS_ROOT}/scripts/cleanup.sh
      exit $?
      ;;
    replace) # preserve positional arguments
      ${SCRIPTS_ROOT}/scripts/make_manage_wsgi.sh
      exit $?
      ;;    
    reload) # preserve positional arguments
      ${SCRIPTS_ROOT}/scripts/reload.sh
      exit $?
      ;;
    help|-h|-?|--help)
      echo "$ artisan_run command   - where command is one of create, clean or replace."
      exit 0
      ;;
    *) # unsupported flags
      echo "Error: Unsupported action $1" >&2
      exit 1
      ;;
  esac
done # set positional arguments in their proper place

#eval set -- "$PARAMS"

echo "I need a command!!"
exit 1