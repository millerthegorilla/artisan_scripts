#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

L_S_FILE=${1}

echo -e "#******************************************************************"
echo -e "#**** you must have downloaded django_artisan to a local dir  *****"
echo -e "#**** and have a password protected user account with a home  *****"
echo -e "#**** directory ready...                                      *****"
echo -e "#******************************************************************"

# PROJECT_NAME
echo -e "#************************** PROJECT_NAME **************************"
isValidVarName() {
    echo "$1" | grep -q '^[_[:alpha:]][_[:alpha:][:digit:]]*$' && return || return 1
}

until isValidVarName "${PROJECT_NAME}"
do
   read -p 'Artisan scripts project name - this is used as a directory name, so must be conformant to bash requirements : ' PROJECT_NAME
   if ! isValidVarName "${PROJECT_NAME}"
   then
       echo -e "That is not a valid variable name.  Your project name must conform to bash directory name standards"
   fi
done

echo "PROJECT_NAME=${PROJECT_NAME}" >> ${L_S_FILE}

# USER_NAME
USER_NAME=${RANDOM}
until id ${USER_NAME} >/dev/null 2>&1;
do
    read -p "Standard/service user account name ['artisan_sysd'] : " USER_NAME
    USER_NAME=${USER_NAME:-"artisan_sysd"}
done
# if [[ $(id ${USER_NAME} > /dev/null 2>&1; echo $?) -ne 0 ]]
# then
#     echo -e "Error, account with username ${USER_NAME} does not exist!"
#     exit 1
# fi

echo "USER_NAME=${USER_NAME}" >> ${L_S_FILE} 

# USER_DIR
pushd / &> /dev/null
read -p "Absolute path to User home dir [ /home/${USER_NAME} ] : " -e USER_DIR
USER_DIR=${USER_DIR:-/home/${USER_NAME}}
popd &> /dev/null

echo "USER_DIR=${USER_DIR}" >> ${L_S_FILE}

# CODE_PATH
pushd / &> /dev/null
until [[ -d "${CODE_PATH}" && ! -L "${CODE_PATH}" ]] 
do
    read -p 'Absolute path to code (the folder where manage.py resides) : ' -e CODE_PATH
    if [[ ! -d "${CODE_PATH}" ]]
    then
       echo -e "That path doesn't exist!"
    fi
    if [[ -L "${CODE_PATH}" ]]
    then
        echo -e "Code path must not be a symbolic link"
    fi
    if [[ ! -d "${CODE_PATH}/media" ]]
    then
        echo -e "There is no media dir in that location. Are you sure?  I will progress anyway.  If it is incorrect, simply stop the script and restart."
    fi
done
popd &> /dev/null

echo "CODE_PATH=${CODE_PATH}" >> ${L_S_FILE}

# DJANGO_PROJECT_NAME
PN=$(basename $(dirname $(find ${CODE_PATH} -name "asgi.py")))
read -p "Enter the name of the django project ie the folder in which wsgi.py resides [${PN}] : " DJANGO_PROJECT_NAME
DJANGO_PROJECT_NAME=${DJANGO_PROJECT_NAME:-${PN}}

echo "DJANGO_PROJECT_NAME=${DJANGO_PROJECT_NAME}" >>  ${L_S_FILE}

# DEBUG
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

echo "DEBUG=${DEBUG}" >> ${L_S_FILE}

if [[ ${DEBUG} == "TRUE" ]]
then
    echo -e "\n*********** The following settings are all optional in debug environment, *********** \
*********** so you can safely click through them. ***********************************\n"
fi

# SITE ADDRESS
if [[ ${DEBUG} == "TRUE" ]]
then
    SITE_ADDRESS="http://127.0.0.1/"
else
    read -p "Enter the site address including protocol ie https://mydomain.com : " SITE_ADDRESS
fi

echo "SITE_ADDRESS=${SITE_ADDRESS}" >> ${L_S_FILE}


## DJANGO_EMAIL_VERIFICATION AND EMAIL MODERATORS ETC
echo -e "#************* email settings ***************"
echo -e "# https://support.google.com/accounts/answer/185833?hl=en"
echo -e "#********************************************"

# EMAIL_APP_ADDRESS
read -p "Your app email server address : " EMAIL_APP_ADDRESS

echo "EMAIL_APP_ADDRESS=${EMAIL_APP_ADDRESS}" >> ${L_S_FILE}

# EMAIL_APP_KEY
read -p "Your app email server address secret password : " EMAIL_APP_KEY

echo "EMAIL_APP_KEY=${EMAIL_APP_KEY}" >> ${L_S_FILE}

# EMAIL_FROM_ADDRESS
if [[ ! -z "$EXTRA_DOMAINS" ]]
then
    return_mail=noreply@${EXTRA_DOMAINS}
else
    return_mail=noreply@$(basename ${SITE_ADDRESS} | sed s'/www.//')
fi

read -p "Your app email from address ie [ ${return_mail} ] : " EMAIL_FROM_ADDRESS 
EMAIL_FROM_ADDRESS=${EMAIL_FROM_ADDRESS:-${return_mail}}

echo "EMAIL_FROM_ADDRESS=${EMAIL_FROM_ADDRESS}" >> ${L_S_FILE}

# CUSTOM_SALT
CUSTOM_SALT="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)"

echo "CUSTOM_SALT=${CUSTOM_SALT}" >> ${L_S_FILE}

## GOOGLE RECPATCHA SETTINGS
echo -e "#************* Google recaptcha settings ***************"
echo -e "# https://developers.google.com/recaptcha/intro "
echo -e "#*****************************************************"

# RECAPTCHA_PUBLIC
read -p "Google Recaptcha public key : " RECAPTCHA_PUBLIC

echo "RECAPTCHA_PUBLIC=${RECAPTCHA_PUBLIC}" >> ${L_S_FILE}

# RECAPTCHA_PRIVATE
read -p "Google Recaptcha private key : "  RECAPTCHA_PRIVATE

echo "RECAPTCHA_PRIVATE=${RECAPTCHA_PRIVATE}" >> ${L_S_FILE}

# DROPBOX_OAUTH_TOKEN
read -p "Dropbox OAuth Token : " DROPBOX_OAUTH_TOKEN

echo "DROPBOX_OAUTH_TOKEN=${DROPBOX_OAUTH_TOKEN}" >> ${L_S_FILE}

# DUCKDNS_TOKEN
source ${CONTAINER_SCRIPTS_ROOT}/setup/utils/make_secret.sh

if [[ ${DEBUG} == "FALSE" ]]
then 
    make_secret DUCKDNS_TOKEN
fi

# AUTO_UPDATES
## add a container label to container run that auto-updates the container every ...
echo -e "\nEnable container updates where possible ? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) AUTO_UPDATES="--label 'io.containers.autoupdate=registry'"; break;;
        No ) AUTO_UPDATES=""; break;;
    esac
done

echo "AUTO_UPDATES=\"${AUTO_UPDATES}\"" >> ${L_S_FILE}