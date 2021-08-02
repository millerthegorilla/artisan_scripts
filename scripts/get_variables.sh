#!/bin/bash

echo -e "\nThe following questions are to fill out the env files that are called upon by the scripts when executing, and by the settings file during production.  The settings .env file is called from the settings file using os.getenv, after the env file is loaded into the environment by the python program dotenv.  This .env file is located in the settings folder, along with settings.py.  You can edit either of those files to edit your site.   Press enter to accept default value[] where listed...\n\n"

echo -e "#******************************************************************"
echo -e "#**** you must have downloaded django_artisan to a local dir  *****"
echo -e "#**** and have a password protected system user account       *****"
echo -e "#**** with a home directory ready                             *****"
echo -e "#******************************************************************"

set -a

read -p 'Artisan scripts project name - this is used as a directory name, so must be conformant to bash requirements : ' project_name
read -p 'Absolute path to code (the django_artisan folder where manage.py resides) : ' CODE_PATH
read -p "Absolute path to User home dir [$(echo ${CODE_PATH} | cut -d/ -f 1-4)] : " USER_DIR
USER_DIR=${USER_DIR:-$(echo ${CODE_PATH} | cut -d/ -f 1-4)}
read -p 'User account name ['$(echo ${CODE_PATH} | cut -d/ -f 4)'] : ' USER_NAME
USER_NAME=${USER_NAME:-$(echo ${CODE_PATH} | cut -d/ -f 4)}

PROJECT_NAME=${project_name}

PN=$(basename $(dirname $(find ${CODE_PATH} -name "asgi.py")))
read -p "Enter the name of the django project ie the folder in which wsgi.py resides [${PN}] : " django_project_name
django_project_name=${django_project_name:-${PN}}
DJANGO_PROJECT_NAME=$django_project_name

if [[ $(type Xorg | echo $?) -eq 0 ]]
then
    XDESK="XDG_RUNTIME_DIR=\"/run/user/$(id -u ${USER_NAME})\" DBUS_SESSION_BUS_ADDRESS=\"unix:path=${XDG_RUNTIME_DIR}/bus\""
else
    XDESK=""
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

echo -e "\n"

echo -e "Enter your....\n"
read -p "Site name as used in the website header/logo : " site_name
if [[ ${DEBUG} == "TRUE" ]]
then
	echo -e "\n*************************************************************************************************"
	echo -e " Since this is a development install you can safely press enter through the rest of the questions."
	echo -e " But you will need to complete the mysql_secure_installation that follow the google recaptcha questions."
	echo -e "*************************************************************************************************"
fi
pod_name=${project_name}_pod
read -p "Pod name [${pod_name}] : " pname
pod_name=${pname:-${pod_name}}

## DJANGO_CONT

# base dir is used in settings_env for base_dir in settings.py
read -p "Container base code directory [/opt/${project_name}/] : " bdir
base_dir=${bdir:-/opt/${project_name}/}
# static base root is in the container
if [[ ${DEBUG} == "TRUE" ]]
then
	SBR="/opt/${project_name}/"
else
	SBR="/etc/opt/${project_name}/static_files/"
fi
read -p "Static base root [${SBR}] : " sbr
static_base_root=${sbr:-${SBR}}

## LOGS
read -p "Host log dir [${HOME}/${project_name}/logs/] : " hld
host_log_dir=${hld:-${HOME}/${project_name}/logs/}
read -p "Swag Host log dir (must be different to Host Log Dir) [${HOME}/${project_name}/swag_logs] : " shld
swag_host_log_dir=${shld:-${HOME}/${project_name}/swag_logs}
# host static dir mounts on to static base root from django and swag conts.

## HOST STATIC
host_static_dir=/etc/opt/${project_name}/static_files/

## SECRET KEYGEN
secret_key=$(tr -dc 'a-z0-9!@#$%^&*(-_=+)' < /dev/urandom | head -c50)

## DATABASE USED BY MARIADB_CONT AND DJANGO_CONT
db_name=${project_name}_db
read -p "Your django database name [${db_name}] : " dbn
db_name=${dbn:-${db_name}}
db_user=${db_name}_user
read -p "Your django database username [${db_user}]: " dbu
db_user=${dbu:-${db_user}}
db_password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
db_host=127.0.0.1
read -p "Your django database host address [${db_host}] : " dbh
db_host=${dbh:-${db_host}}

## DUCKDNS
read -p "Duckdns domain : " duckdns_domain
echo -e "\nDo you have a top level domain pointing at your duckdns domain ? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) tldomain="TRUE"; break;;
        No ) tldomain="FALSE"; break;;
    esac
done
if [[ ${tldomain} == "TRUE" ]]
then
    read -p "Your top level domain that points at your duckdns domain : " tl_domain
    EXTRA_DOMAINS="${tl_domain}"
else
    EXTRA_DOMAINS="NONE"
fi
DUCKDNS_SUBDOMAIN="${duckdns_domain}"

## DJANGO_EMAIL_VERIFICATION AND EMAIL MODERATORS ETC
echo -e "#************* email settings ***************"
echo -e "# https://support.google.com/accounts/answer/185833?hl=en"
echo -e "#********************************************"
read -p "Your app email server address : " email_app_address
read -p "Your app email server address secret password : " email_app_key
if [[ ! -z "$tl_domain" ]]
then
    return_mail=noreply@${tl_domain}
else
    return_mail=noreply@${duckdns_domain}
fi
read -p "Your app email from address ie [${return_mail}] : " efa
email_from_address=${efa:-${return_mail}}
custom_salt=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

## GOOGLE RECPATCHA SETTINGS
echo -e "#************* Google recaptcha settings ***************"
echo -e "# https://developers.google.com/recaptcha/intro "
echo -e "#*****************************************************"
read -p "Google Recaptcha public key : " recaptcha_public
read -p "Google Recaptcha private key : " recaptcha_private
recaptcha_public="${recaptcha_public}"
recaptcha_private="${recaptcha_private}"

## system user account name
read -p "System Account Name for systemd units ['artisan_sysd'] : " systemd_user
systemd_user=${systemd_user:-"artisan_sysd"}
if [[ $(id ${systemd_user} > /dev/null 2>&1; echo $?) -ne 0 ]]
then
    echo -e "Error, account with username ${systemd_user} does not exist!"
    exit 1
else
    if [[ $(id -u ${systemd_user}) -ge 1000 ]]
    then
        echo -e "Error, ${systemd_user} account is not a system account"
    fi
fi

if [[ ${DEBUG} == "TRUE" ]]
then
    django_image="python:${PROJECT_NAME}_debug"
else
    django_image="python:${PROJECT_NAME}_prod"
fi
set +a

cp -ar ${CODE_PATH}/media ${SCRIPTS_ROOT}/dockerfiles/django/media

## parameters : prompt (string), secret name
function make_secret()
{  
    if [[ $(runuser --login -u ${USER_NAME} -- ${XDESK} podman secret inspect ${1} &>/dev/null; echo $?) == 0 ]]
    then
        echo -e "podman secret ${1} already exists - reuse ?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) REUSE="TRUE"; break;;
                No ) REUSE="FALSE"; break;;
            esac
        done
        if [[ ${REUSE} == "FALSE" ]]
        then
            runuser --login -u ${USER_NAME} -- ${XDESK} podman secret rm ${1}
            read -p "Enter variable for ${1} : " token && echo -n "$token" | su "${USER_NAME}" --login -c "${XDESK} podman secret create \"${1}\" -" 
        fi
    else
        read -p "Enter variable for ${1} : " token && echo -n "$token" | su "${USER_NAME}" --login -c "${XDESK} podman secret create \"${1}\" -"
    fi

}

if [[ ${DEBUG} == "FALSE" ]]
then 
    make_secret DUCKDNS_TOKEN
fi

make_secret MARIADB_ROOT_PASSWORD

# variables for create_directories.sh
runuser --login -u ${USER_NAME} "(
echo PROJECT_NAME=${PROJECT_NAME} > .proj
echo USER_NAME=${USER_NAME} >> .proj
echo USER_DIR=${USER_DIR} >> .proj
echo SCRIPTS_ROOT=${SCRIPTS_ROOT} >> .proj
echo CODE_PATH=${CODE_PATH} >> .proj
echo EXTRA_DOMAINS=${EXTRA_DOMAINS} >> .proj
echo DUCKDNS_SUBDOMAIN=${DUCKDNS_SUBDOMAIN} >> .proj
echo DEBUG=${DEBUG} >> .proj
echo XDESK=${XDESK} >> .proj
### TEMPLATES
cat ${SCRIPTS_ROOT}/templates/env_files/scripts_env | envsubst > ${SCRIPTS_ROOT}/.env
cat ${SCRIPTS_ROOT}/templates/env_files/settings_env | envsubst > ${SCRIPTS_ROOT}/settings/settings_env
cat ${SCRIPTS_ROOT}/templates/settings/archive | envsubst > ${SCRIPTS_ROOT}/.archive
cat ${SCRIPTS_ROOT}/templates/django/manage.py | envsubst > ${CODE_PATH}/manage.py
cat ${SCRIPTS_ROOT}/templates/django/wsgi.py | envsubst > ${CODE_PATH}/${django_project_name}/wsgi.py
cat ${SCRIPTS_ROOT}/templates/gunicorn/start |  envsubst > ${SCRIPTS_ROOT}/dockerfiles/django/start.sh

if [[ ${DEBUG} == "FALSE" ]]
then
    set -a
        NUM_OF_WORKERS=$(($(nproc --all) * 2 + 1))
    set +a
    cat ${SCRIPTS_ROOT}/templates/gunicorn/gunicorn.conf.py | envsubst > ${SCRIPTS_ROOT}/settings/gunicorn.conf.py
    if [[ ${tldomain} == "TRUE" ]]
    then
        cat ${SCRIPTS_ROOT}/templates/swag/default_tld | envsubst '$tl_domain:$duckdns_domain' > ${SCRIPTS_ROOT}/dockerfiles/swag/default
    else
        cat ${SCRIPTS_ROOT}/templates/swag/default | envsubst '$duckdns_domain' > ${SCRIPTS_ROOT}/dockerfiles/swag/default
    fi
fi
)"
### Systemd system account creation


unset site_name
unset pod_name
unset base_dir
unset static_base_root
unset host_log_dir
unset swag_host_static_dir
unset secret_key
unset tl_domain
unset duckdns_domain
unset duckdns_token
unset db_name
unset db_user
unset db_password
unset email_app_address
unset email_app_key
unset email_from_address
unset custom_salt
unset recaptcha_public
unset recaptcha_private
