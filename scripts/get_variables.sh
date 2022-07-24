#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

source ${SCRIPTS_ROOT}/options

echo -e "Enter absolute filepath of project variables or press enter to accept default.\n \
         If the default does not exist, then you can enter the variables manually...\n"
read -p ": " -e PROJECT_FILE

if ![[ -n ${PROJECT_FILE} && -f ${PROJECT_FILE} ]];
then
    cp ${PROJECT_FILE} ./.proj
elif [[ -n ${DEFAULT_PROJECT_FILE} && -f ${DEFAULT_PROJECT_FILE} ]]; then
    cp ${DEFAULT_PROJECT_FILE} ./.proj
else
    get_variables_and_make_project_file()
fi

function get_variables_and_make_project_file()
{
    set -a
        CONTAINER_SCRIPTS_ROOT="${SCRIPTS_ROOT}/container_scripts"
    set +a
    
    source ${CONTAINER_SCRIPTS_ROOT}/.questions.sh
    
    for container in $(ls -d ${CONTAINER_SCRIPTS_ROOT}/containers/*)
    do
        source ${container}/variables/questions.sh
    done

    # dockerfile_app_names=""
    # if [[ ${DEBUG} == "TRUE" ]]
    # then
    #     echo -e 'mount app source code directories? - note that repository name must be indentical to the contained app name.'
    #     select yn in "Yes" "No"; do
    #         case $yn in
    #             Yes ) MOUNT_SRC_CODE="TRUE"; break;;
    #             No ) MOUNT_SRC_CODE="FALSE"; break;;
    #         esac
    #     done
    #     if [[ ${MOUNT_SRC_CODE} == "TRUE" ]]
    #     then
    #         cd /
    #         until [[ -d "${SRC_CODE_PATH}" && ! -L "${SRC_CODE_PATH}" ]] 
    #         do
    #             echo -e 'mount source code directories (1) or mount git directories (2)'
    #             select sg in "src" "git"; do
    #                 case $sg in
    #                     src ) MOUNT_GIT="FALSE"; break;;
    #                     git ) MOUNT_GIT="TRUE"; break;;
    #                 esac
    #             done
    #             if [[ ${MOUNT_GIT} == "TRUE" ]]
    #             then
    #                 SMSG='Symlinks will be to the git repository which can allow you to use git submodules to track your code changes.'
    #             else
    #                 SMSG='Symlinks will be to the source code directories inside the git repository.  You will have to manually track source code changes, updating each git in each repository.'
    #             fi
    #             echo -e 'Absolute path to git repository (the folder where your app directories reside) - *IMPORTANT* There must only be git repository directories at this path, ie each subdirectory of this path must be of the form "app_name" which must be a git repository for your app, and must have the subdirectory "app_name" containing the django_source_code.'
    #             echo -e ${SMSG}
    #             read -p ":" -e SRC_CODE_PATH
    #             if [[ ! -d "${SRC_CODE_PATH}" ]]
    #             then
    #                echo -e "That path doesn't exist!"
    #             fi
    #             if [[ -L "${SRC_CODE_PATH}" ]]
    #             then
    #                 echo -e "Code path must not be a symbolic link"
    #             fi
    #         done
    #         # constructs a dockerfile RUN command that makes the various directories for the source code
    #         dockerfile_app_names="RUN "
    #         for app_name in $(ls ${SRC_CODE_PATH});
    #         do 
    #             dockerfile_app_names="${dockerfile_app_names}mkdir -p /opt/${PROJECT_NAME}/${app_name}; "
    #         done
    #     fi
    # fi

 
} # end of get_variables_and_make_project_file