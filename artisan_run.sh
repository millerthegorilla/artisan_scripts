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
set +a

function install_check()
{
  INSTALLED="installed."
    if [[ "550" -ne $(stat -c '%a' ${SCRIPTS_ROOT}/artisan_run.sh) ]];
    then
      ERROR=": ERR1 artisan_run.sh"
      INSTALLED="not installed"
    fi
    for line in $(find ${SCRIPTS_ROOT}/scripts -type d);
    do
      if [[ "550" -ne $(stat -c '%a' ${line}) ]];
      then
        ERROR=": ERR2 $line"
        INSTALLED="not installed!";
        break;
      fi
    done
    if [[ $INSTALLED == "installed." ]];
    then
      for line in $(find ${SCRIPTS_ROOT}/scripts -type f)
      do
        if [[ "440" -ne $(stat -c '%a' ${line}) ]];
        then
          ERROR=": ERR3 $line"
          INSTALLED="not installed!"
          break;
        fi
      done
    fi
    if [[ $INSTALLED == "installed." ]];
    then
      for line in $(find ${CONTAINER_SCRIPTS_ROOT} -type f -executable)
      do
        if [[ ${line} ]];
        then
          ERROR=": ERR4 - executable found - $line"
          INSTALLED="not installed!";
          break;
        fi
      done
    fi
    if [[ $INSTALLED == "installed." ]];
    then
      for line in $(find ${SCRIPTS_ROOT}/.git -type d)
      do
        if [[  "550" -ne $(stat -c '%a' ${line}) ]];
        then
          ERROR=": ERR5 $line"
          INSTALLED="not installed!";
          break;
        fi
      done
    fi;
    if [[ $INSTALLED == "installed." ]];
    then
      for line in $(find ${SCRIPTS_ROOT}/.git/objects -type f) 
      do
        if [[ "444" -ne $(stat -c '%a' ${line}) ]];
        then
          ERROR=": ERR6 $line"
          INSTALLED="not installed!";
          break;
        fi
     done
   fi
   if [[ $INSTALLED == "installed." ]];
    then
      for line in $(find ${SCRIPTS_ROOT}/.git -type f | grep -v /objects/ ) 
      do
        if [[ "640" -ne $(stat -c '%a' ${line}) ]];
        then
          ERROR=": ERR7 $line"
          INSTALLED="not installed!";
          break;
        fi
     done
   fi

  echo -e "Scripts are ${INSTALLED} $ERROR";
}

if [[ "$1" != "install" && "$1" != "uninstall" ]]; then
    install_check;
fi

while (( "$#" )); do
  case "$1" in
    install)
      bash ${SCRIPTS_ROOT}/scripts/install.sh -r
      install_check
      exit $?
      ;;
    uninstall)
      bash ${SCRIPTS_ROOT}/scripts/uninstall.sh -r
      install_check
      exit $?
      ;;
    create)
      labels=()
      iarray=()
      alllabels=('variables' 'templates' 'directories' 'network' 'pull' 'build' 'settings' 'pods' 'containers' 'systemd')
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
              vars['templates']=1
              vars['directories']=2
              vars['network']=3
              vars['pull']=4
              vars['build']=5
              vars['settings']=6
              vars['pods']=7
              vars['containers']=8
              vars['systemd']=9
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
                bash ${SCRIPTS_ROOT}/scripts/get_variables.sh
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'TEMPLATES')
                echo -e "\nOkay, lets find out more about you...\n"
                bash ${SCRIPTS_ROOT}/scripts/templates.sh
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'DIRECTORIES')
                echo -e "\nNow I will create necessary directtories.\n"
                bash ${SCRIPTS_ROOT}/scripts/create_directories.sh
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'NETWORK')
                echo -e "\nNow for general network settings.\n"
                bash ${SCRIPTS_ROOT}/scripts/create_network.sh
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'PULL')
                echo -e "\nI will now download container images, if they are not already present.\n"
                bash ${SCRIPTS_ROOT}/scripts/image_acq.sh
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'BUILD')
                echo -e "\nI will now build any custom container images, if they are not already present.\n"
                bash ${SCRIPTS_ROOT}/scripts/image_build.sh
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'SETTINGS')
                echo -e "\n please choose the settings file you want to use.\n"
                bash ${SCRIPTS_ROOT}/scripts/settings.sh
            ;;
            'PODS')
                echo -e "\n I will create the pods.\n"
                bash ${SCRIPTS_ROOT}/scripts/create_pods.sh
            ;;
            'CONTAINERS')
                echo -e "\n and now I will create the containers...\n"
                bash ${SCRIPTS_ROOT}/scripts/create_containers.sh
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
                    bash ${SCRIPTS_ROOT}/scripts/systemd.sh
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
      bash ${SCRIPTS_ROOT}/scripts/cleanup.sh
      exit $?
      ;;
    clean_save_settings)
      bash ${SCRIPTS_ROOT}/scripts/clean_save_settings.sh
      exit $?
      ;; 
    custom)
      shift;      
      bash $(find ${CONTAINER_SCRIPTS_ROOT}/containers -name "${1}.sh")
      exit $?
      ;;   
    status)
      #install_check
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
      then   # TODO function for below
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
      runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"chown artisan:artisan /etc/opt/${PROJECT_NAME}/settings/settings.py\""
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
      ${SCRIPTS_ROOT}/scripts/image_acq.sh
      ${SCRIPTS_ROOT}/scripts/image_build.sh
      systemctl reboot
      ;;
    help|-h|-?|--help)
      echo -e "$ artisan_run command   - where command is one of clean,
create [ variables, directories, images, containers, systemd ],
install, interact, manage, pip, postgit, refresh, replace, reload, status,
settings, update or help.

appsrc - clones app src directories from a repository, ie github, by cloning
         each address in a file of addresses one at a time into a specified directory.

clean - cleans the project, deleting the containers and pod, and deleting 
        settings files etc.

create - on its own creates a new project, running through the various stages
    which are:
       variables - gets variables from user
       directories - creates the directories and lowers the machine's port 
                     numbers from 1024 to 80
       images - pulls the podman images and creates the custom images - can
                take a long time.
       containers - creates the containers from the container scripts
       systemd - creates and installs the systemd units
    Use any combination of the stage names after the create verb to perform
    those stages.

install - when you first clone the repository, you can set the appropriate 
          permissions using this verb.

interact - commands following the interact verb will be run inside the podman
           pod using systemd context.  You are often better to run 
           'podman pod exec -it container_name bash' in the user account.

manage - connects to the python manage.py command inside the pod.  Run with 
         any manage commmand ie.  sudo ./artisan_run.sh manage createsuperuser.

pip - enters a venv inside the django container and runs pip with the commands
      that you supply.
      
postgit - in case you reinstall django_artisan filebase completes and copies
          manage.py and wsgi.py and copies them to the appropriate places and
          sets the file and directory permissions inside the container correctly

refresh - deletes all images, downloads them and rebuilds the custom images.

replace - replaces manage.py and wsgi.py.

reload - for production use only, kills and restarts the gunicorn process.

status - reports the current status of the project.

settings - replaces the settings file with one you choose from the 
           dev/production directory.

tests_on - changes database permissions sufficient to allow tests to be run

tests_off - changes database permissions back to minimal set, depending on
            whether project is debug or production.

update - runs apt-get update in all the containers.  Note that when you create a
         project you can specify that the containers are updated where possible,
         which will be done automatically by podman.

help - this text."
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
