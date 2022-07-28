#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

PARAMS=""

export SCRIPTS_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [[ -e ${SCRIPTS_ROOT}/options ]]
then
    while read LINE
    do
      if echo ${LINE} | grep -e "^#" >/dev/null 2>&1
      then
          export ${LINE}
      fi
    done
fi

function install_check()
{
  INSTALLED="installed."
 # should have used a case statement.... doh.
    for line in $(find . -type d);
    do
      if [[ ${line:0:6} != "./.git" \
             && ${line:0:26} != "./dockerfiles/django/media" \
             && ${line:0:16} != "./settings_files"
             && ${line:0:19} != "./container_scripts" \
             && "555" -ne $(stat -c '%a' ${line}) ]];
      then
        ERROR=": ERR1 $line"
        INSTALLED="not installed!";
        break;
      elif [[ ${line:0:6} == "./.git" && "550" -ne $(stat -c '%a' ${line}) ]];
      then
        ERROR=": ERR2 $line"
        INSTALLED="not installed!";
        break;
      elif [[ ${line:0:26} == "./dockerfiles/django/media" && "770" -ne $(stat -c '%a' ${line}) ]];
      then
        ERROR=": ERR3 $line"
        INSTALLED="not installed!";
        break;
      fi
    done
    if [[ $INSTALLED == "installed." ]];
    then
      for line in $(find -type f -name "*.sh")
      do
        if [[ ${line:0:18} != "./templates/maria/" \
             && ${line:0:20} != "./container_scripts/" \
             && "550" -ne $(stat -c '%a' ${line}) ]];
        then
          ERROR=": ERR4 $line"
          INSTALLED="not installed!"
          break;
        elif [[ ${line:0:18} == "./templates/maria/" && "440" -ne $(stat -c '%a' ${line}) ]];
        then
          ERROR=": ERR5 $line"
          INSTALLED="not installed!"
          break;
        fi
      done
    fi
    if [[ $INSTALLED == "installed." ]];
    then
      for line in $(find ./dockerfiles/django/media -type d)
      do
        if [[  "770" -ne $(stat -c '%a' ${line}) ]];
        then
          ERROR=": ERR6 $line"
          INSTALLED="not installed!";
          break;
        fi
      done
    fi
    if [[ $INSTALLED == "installed." ]];
    then
      for line in $(find ./dockerfiles/django/media -type f)
      do
        if [[  "440" -ne $(stat -c '%a' ${line}) ]];
        then
          ERROR=": ERR7 $line"
          INSTALLED="not installed!";
          break;
        fi
      done
    fi;
    if [[ $INSTALLED == "installed." ]];
    then
      for line in $(find ./dockerfiles/django/media -type f) 
      do
        if [[  "440" -ne $(stat -c '%a' ${line}) ]];
        then
          ERROR=": ERR8 $line"
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
      find . -type d | xargs chmod 0555
      find . -type f | xargs chmod 0444
      find ./container_scripts -type f -name "*.sh" | xargs chmod 0660
      find ./container_scripts -type d | xargs chmod 0775
      find ./scripts -type f -name "*.sh" | xargs chmod 0550
      find .git -type d | xargs chmod 0550
      find .git/objects -type f | xargs chmod 444
      find .git -type f | grep -v /objects/ | xargs chmod 644
      chmod 0440 templates/maria/maria_prod.sh
      chmod 0440 templates/maria/maria_dev.sh
      find ./dockerfiles/django/media -type d | xargs chmod 770
      find ./dockerfiles/django/media -type f | xargs chmod 440
      find . -type d | xargs chown ${SUDO_USER}:${SUDO_USER}
      find . -type f | xargs chown ${SUDO_USER}:${SUDO_USER}
      find ./settings_files -type d | xargs chmod 750
      find ./settings_files -type d | xargs chown root:root
      chmod 0550 ./artisan_run.sh
      install_check
      exit $?
      ;;
    uninstall)
      SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
      OWNER_NAME=$(stat -c "%U" ${SCRIPT_DIR})
      find . | xargs chown ${OWNER_NAME}:${OWNER_NAME}
      find . -type d | xargs chmod 0775
      find . -type f | xargs chmod 0660
      find ./scripts -type f -name "*.sh" | xargs chmod 0660
      find .git -type d | xargs chmod 755
      find .git/objects -type f | xargs chmod 664
      find .git -type f | grep -v /objects/ | xargs chmod 644
      chmod 0775 ./artisan_run.sh
      install_check
      exit $?
      ;;
    create)
      labels=()
      iarray=()
      alllabels=('variables' 'directories' 'network' 'images' 'containers' 'systemd')
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
              vars['network']=2
              vars['images']=3
              vars['containers']=4
              vars['systemd']=5
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
                ${SCRIPTS_ROOT}/scripts/get_variables.sh -r
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'DIRECTORIES')
                echo -e "\nNow I will create necessary directtories.\n"
                ${SCRIPTS_ROOT}/scripts/create_directories.sh -r
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'NETWORK')
                echo -e "\nNow for general network settings.\n"
                ${SCRIPTS_ROOT}/scripts/create_network.sh -r
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'IMAGES')
                echo -e "\nI will now download and provision container images, if they are not already present.\n"
                ${SCRIPTS_ROOT}/scripts/initial_provision.sh -r
                if [[ $? -ne 0 ]]
                then
                  exit $?
                fi
            ;;
            'CONTAINERS')
                echo -e "\n and now I will create the containers...\n"
                ${SCRIPTS_ROOT}/scripts/create_all.sh -r
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
                    SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_generate.sh -r
                    SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_user_init.sh -r 
                    SCRIPTS_ROOT=${SCRIPTS_ROOT} ${SCRIPTS_ROOT}/scripts/systemd_user_enable.sh -r
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
    clean_save_settings)
      ${SCRIPTS_ROOT}/scripts/clean_save_settings.sh
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
    # output)
    #   if [[ -z ${USER_NAME} ]]
    #   then
    #       read -p "Enter username : " USER_NAME
    #   fi
    #   if [[ -z ${DJANGO_CONT_NAME} ]]
    #   then
    #       read -p "Enter the name of the django container : " DJANGO_CONT_NAME
    #   fi
    #   su ${USER_NAME} -c "cd; podman exec -it ${DJANGO_CONT_NAME} tail -f /tmp/manage_output"
    #   exit $?
    #   ;;
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
    pip)
      shift;
      COMMANDS="$*"
      runuser --login ${USER_NAME} -P -c "podman exec -e PROJECT_NAME=${PROJECT_NAME} -it ${DJANGO_CONT_NAME} bash -c \"runuser -s /bin/bash artisan -c 'source /home/artisan/django_venv/bin/activate && pip ${COMMANDS}'\""
      exit $?
      ;;
    appsrc)
      if [[ -z ${USER_NAME} ]]
      then
          read -p "Enter username : " USER_NAME
      fi
      read -p "File with github addresses : " -e GITFILE
      read -p "Directory to clone into : " -e GITDIR
      LINES=$(cat ${GITFILE})
      for line in $LINES
      do
        runuser --login ${USER_NAME} -P -c "git -C ${GITDIR} clone ${line}"
      done
      exit $?
      ;;
    tests_on)
      if [[ -z ${MARIA_CONT_NAME} ]]
      then
        echo "No database container is found!";
        exit 1;
      fi
      read -p "Database root password? : " ROOT_PWD
      runuser --login ${USER_NAME} -P -c "podman exec -it ${MARIA_CONT_NAME} bash -c \"echo 'grant all on *.* to ${DB_USER}@${DB_HOST}; flush privileges;' | mysql -uroot -p${ROOT_PWD}\""
      exit $?
      ;;
    tests_off)
      if [[ -z ${MARIA_CONT_NAME} ]]
      then
        echo "No database container is found!";
        exit 1;
      fi
      read -p "Database root password? : " ROOT_PWD
      runuser --login ${USER_NAME} -P -c "podman exec -it ${MARIA_CONT_NAME} bash -c  \"echo 'revoke all privileges, grant option from ${DB_USER}@${DB_HOST}; flush privileges;' | mysql -uroot -p${ROOT_PWD}\""
      if [[ ${DEBUG} == "TRUE" ]]
      then
        runuser --login dev -P -c "podman exec -it mariadb_cont bash -c \"echo 'GRANT DROP, CREATE, ALTER, INDEX, SELECT, UPDATE, INSERT, DELETE, LOCK TABLES ON ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} IDENTIFIED BY \\\"${DB_PASSWORD}\\\"; flush privileges;' | mysql -uroot -p${ROOT_PWD}\""
      else
        runuser --login dev -P -c "podman exec -it mariadb_cont bash -c \"echo 'GRANT CREATE, ALTER, INDEX, SELECT, UPDATE, INSERT, DELETE ON ${DB_NAME}.* TO ${DB_USER}@${DB_HOST} IDENTIFIED BY \\\"${DB_PASSWORD}\\\"; flush privileges;' | mysql -uroot -p${ROOT_PWD}\""
      fi
      exit $?
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