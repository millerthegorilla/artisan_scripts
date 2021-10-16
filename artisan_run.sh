#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

PARAMS=""

set -a
SCRIPTS_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [[ -e ${SCRIPTS_ROOT}/options ]]
then
    source ${SCRIPTS_ROOT}/options
fi
if [[ -e ${SCRIPTS_ROOT}/.archive ]]
then
    source ${SCRIPTS_ROOT}/.archive
fi
set +a

while (( "$#" )); do
  case "$1" in
    install)
      ## added this option to archive it.
      chown root:root -R * *.
      find . -type d -exec chmod 0550 {} +
      find . -type f -exec chmod 0440 {} +
      chmod 0550 -R *.sh
      find .git -type d | xargs chmod 755
      find .git/objects -type f | xargs chmod 444
      find .git -type f | grep -v /objects/ | xargs chmod 644
      exit $?
      ;;
    create)
      labels=()
      iarray=()
      alllabels=('variables' 'directories' 'images' 'containers' 'systemd')
      parray=( "${@:2}" )
      if [[ ${#parray} -gt 0 ]]
      then
          if [[ ${parray[0]^^} == 'ALL' ]]
          then
              labels=( ${alllabels[@]} )
          else
              # labels=${parray[@]:1}
              declare -A vars
              vars['variables']=0
              vars['directories']=1
              vars['images']=2
              vars['containers']=3
              vars['systemd']=4
              i=0
              for j in "${parray[@]}"
              do
                  iarray[$i]=${vars[$j]}
                  i=$i+1
              done
              IFS=$'\n' sorted=($(sort <<<"${iarray[*]}"))
              unset IFS
              i=0
              for j in "${sorted[@]}"
              do
                 labels[i]="${alllabels[$j]}"
                 i=$i+1
              done
          fi
      else
          labels=( ${alllabels[@]} )
      fi
      if [[ ${#labels[@]} -eq 0 ]]
      then
        labels=( ${parray[@]} )
      fi
      for i in "${labels[@]}"
      do
          case "${i^^}" in
            'VARIABLES')
                echo -e "\nOkay, lets find out more about you...\n"
                ${SCRIPTS_ROOT}/scripts/get_variables.sh
            ;;
            'DIRECTORIES')
                echo -e "\nNow I will create the directtories, and I will open ports below 1024 on this machine.\n"
                ${SCRIPTS_ROOT}/scripts/create_directories.sh
            ;;
            'IMAGES')
                echo -e "\nI will now download and provision container images, if they are not already present.\n"
                ${SCRIPTS_ROOT}/scripts/initial_provision.sh
            ;;
            'CONTAINERS')
                echo -e "\n and now I will create the containers...\n"
                ${SCRIPTS_ROOT}/scripts/create_all.sh
            ;;
            'SYSTEMD')
                echo -e "\n fancy some systemd?...\n"
                echo -e "Generate and install systemd --user unit files? : "
                select yn in "Yes" "No"; do
                    case $yn in
                        Yes ) SYSD="TRUE"; break;;
                        No ) SYSD="FALSE"; break;;
                    esac
                done
                if [[ ${SYSD} == "TRUE" ]]
                then
                    SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_generate.sh
                    SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_user_init.sh
                    SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_user_enable.sh
                fi
            ;;
            *)
                echo -e "Error: unknown option passed to create : ${i^^}"
                exit 1
            ;;
          esac
      done
      exit $? 
      ;;
    clean)
      ${SCRIPTS_ROOT}/scripts/cleanup.sh
      exit $?
      ;;
    replace)
      ${SCRIPTS_ROOT}/scripts/make_manage_wsgi.sh
      exit $?
      ;;    
    reload) 
      ${SCRIPTS_ROOT}/scripts/reload.sh
      exit $?
      ;;
    status)
      if [[ -n "${USER_NAME}" ]]
      then
          echo -e "User is ${USER_NAME}"
      else
          echo -e "User is unset!"
      fi
      if [[ -n ${POD_NAME} ]]
      then
          if [[ $(runuser --login ${USER_NAME} -c "podman pod exists ${POD_NAME}"; echo $?) -eq 0 ]]
          then         
              echo -e "pod ${POD_NAME} exists!  State is $(runuser --login ${USER_NAME} -c "podman pod inspect ${POD_NAME}" | grep -m1 State)"
              exit 0
          else
              echo -e "pod ${POD_NAME} doesn't exist - but there are settings files - you might want to clean up dot settings files manually, or run artisan_run clean"
              exit 1
          fi
      else
        echo -e "No project running currently"
      fi
      exit 1
      ;;
    manage) ## TODO - if the below variables don't exist then save them.
      if [[ -z "${DJANGO_CONT_NAME}" ]]
      then
        read -p "Enter the name of the container running python/django : " DJANGO_CONT_NAME
      fi
      if [[ -z "${PROJECT_NAME}" ]]
      then
        read -p "Enter your artisan_scripts project name : " PROJECT_NAME
      fi
      shift;
      COMMANDS="$*"
      runuser --login ${USER_NAME} -c "podman exec -e COMMANDS=\"$*\" -e PROJECT_NAME=${PROJECT_NAME} -e PYTHONPATH=\"/etc/opt/${PROJECT_NAME}/settings/:/opt/${PROJECT_NAME}/\" -it ${DJANGO_CONT_NAME} bash -c \"cd opt/${PROJECT_NAME}; python manage.py ${COMMANDS}\""
      exit $?
      ;;
    settings)
      if [[ -z "${PROJECT_NAME}" ]]
      then
        read -p "Enter your artisan_scripts project name : " PROJECT_NAME
      fi
      if [[ -z "${DEBUG}" ]]
      then
        echo -e "\nIs this development ie debug? : "
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) DEBUG="TRUE"; break;;
                No ) DEBUG="FALSE"; break;;
            esac
        done
      fi
      if [[ -n "${CURRENT_SETTINGS}" ]]
      then
          echo -e "\nCurrent Settings is ${CURRENT_SETTINGS}"
      fi
      if [[ ${DEBUG} == "TRUE" ]]   ## TODO function 
      then
          echo "Please select the settings file from the list"

          files=$(ls ${SCRIPTS_ROOT}/settings/development)
          i=1

          for j in $files
          do
          echo "$i.$j"
          file[i]=$j
          i=$(( i + 1 ))
          done

          echo "Enter number"
          read input
          cp ${SCRIPTS_ROOT}/settings/development/${file[${input}]} ${SCRIPTS_ROOT}/settings/settings.py 
      else
          echo "Please select the settings file from the list"

          files=$(ls ${SCRIPTS_ROOT}/settings/production)
          i=1

          for j in $files
          do
          echo "$i.$j"
          file[i]=$j
          i=$(( i + 1 ))
          done
          echo "Enter number"
          read input
          cp ${SCRIPTS_ROOT}/settings/production/${file[${input}]} ${SCRIPTS_ROOT}/settings/settings.py
      fi
      sed -i '/CURRENT_SETTINGS/d' ${SCRIPTS_ROOT}/.archive
      echo "CURRENT_SETTINGS="${file[${input}]} >> ${SCRIPTS_ROOT}/.archive
      cp ${SCRIPTS_ROOT}/settings/settings.py /etc/opt/${PROJECT_NAME}/settings
      su ${USERNAME} -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan /etc/opt/${PROJECT_NAME}/settings/settings.py\""
      exit $?
      ;;
    interact)
      if [[ -z ${USER_NAME} ]]
      then
          read -p "Enter username : " USER_NAME
      fi
      runuser --login ${USER_NAME} -P -c "XDG_RUNTIME_DIR=\"/run/user/$(id -u ${USER_NAME})\" DBUS_SESSION_BUS_ADDRESS=\"unix:path=${XDG_RUNTIME_DIR}/bus\" cd; ${2}"
      exit $?
      ;;
    output)
      if [[ -z ${USER_NAME} ]]
      then
          read -p "Enter username : " USER_NAME
      fi
      if [[ -z ${DJANGO_CONT_NAME} ]]
      then
          read -p "Enter the name of the django container : " DJANGO_CONT_NAME
      fi
      su ${USER_NAME} -c "cd; podman exec -it ${DJANGO_CONT_NAME} tail -f /tmp/manage_output"
      exit $?
      ;;
    update)
      if [[ -z ${USER_NAME} ]]
      then
          read -p "Enter username : " USER_NAME
      fi
      su ${USER_NAME} -c "cd; podman ps --format=\"{{.Names}}\" | grep -oP '^((?!infra).)*$' | while read name; do podman exec -u root ${name} bash -c \"apt-get update; apt-get upgrade -y\"; done"
      exit $?
      ;;
    refresh)
      if [[ -z ${USER_NAME} ]]
      then
          read -p "Enter username : " USER_NAME
      fi
      if [[ -z ${POD_NAME} ]]
      then
          read -p "Enter username : " POD_NAME
      fi
      su ${USER_NAME} -c "cd; podman pod stop ${POD_NAME}; podman image prune --all -f"
      ${SCRIPTS_ROOT}/scripts/initial_provision.sh
      systemctl reboot
      ;;
    postgit)
      if [[ -z ${USER_NAME} ]]
      then
          read -p "Enter username : " USER_NAME
      fi
      if [[ -z ${PROJECT_NAME} ]]
      then
          read -p "Enter project name : " PROJECT_NAME
      fi
      if [[ -z ${DJANGO_CONT_NAME} ]]
      then
          read -p "Enter django container name : " DJANGO_CONT_NAME
      fi
      ${SCRIPTS_ROOT}/scripts/make_manage_wsgi.sh
      runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /opt/${PROJECT_NAME}&& find /opt/${PROJECT_NAME} -type d -exec chmod 0550 {} + && find /opt/${PROJECT_NAME} -type f -exec chmod 0440 {} +\""
      runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan -R /etc/opt/${PROJECT_NAME} && find /etc/opt/${PROJECT_NAME} -type f -exec chmod 0440 {} + && find /etc/opt/${PROJECT_NAME} -type d -exec chmod 0550 {} +\""
      ;;
    help|-h|-?|--help)
      echo "$ artisan_run command   - where command is one of create, clean, replace, manage or settings."
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