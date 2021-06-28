#!/bin/bash

echo -e "\nThe following questions are to fill out the env files that are called upon by the scripts when executing, and by the settings file during production.  The settings .env file is called from the settings file using os.getenv, after the env file is loaded into the environment by the python program dotenv.  This .env file is located in the settings folder, along with settings.py.  You can edit either of those files to edit your site.   Press enter to accept default value[] where listed...\n\n"

echo -e "#******************************************************************"
echo -e "#**** you must have downloaded django_artisan to a local dir  *****"
echo -e "#******************************************************************"

set -a

read -p 'Artisan scripts project name - this is used as a directory name, so must be conformant to bash requirements : ' project_name
read -p 'Absolute path to code (the django_artisan folder where manage.py resides) : ' CODE_PATH
read -p "Absolute path to User home dir [$(echo ${CODE_PATH} | cut -d/ -f 1-4)] : " USER_DIR
USER_DIR=${USER_DIR:-$(echo ${CODE_PATH} | cut -d/ -f 1-4)}
read -p 'User account name ['$(echo ${CODE_PATH} | cut -d/ -f 4)'] : ' USER
USER=${USER:-$(echo ${CODE_PATH} | cut -d/ -f 4)}

PROJECT_NAME=${project_name}

PN=$(basename $(dirname $(find ${CODE_PATH} -name "asgi.py")))
read -p "Enter the name of the django project ie the folder in which wsgi.py resides [${PN}] : " django_project_name
django_project_name=${django_project_name:-${PN}}

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
read -p "Your top level domain that points at your duckdns domain : " tld_domain
EXTRA_DOMAINS="${tld_domain}"
DUCKDNS_SUBDOMAIN="${duckdns_domain}"

## DJANGO_EMAIL_VERIFICATION AND EMAIL MODERATORS ETC
echo -e "#************* email settings ***************"
echo -e "# https://support.google.com/accounts/answer/185833?hl=en"
echo -e "#********************************************"
read -p "Your app email server address : " email_app_address
read -p "Your app email server address secret password : " email_app_key
if [[ ! -z "$tld_domain" ]]
then
    return_mail=noreply@${tld_domain}
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
set +a

## parameters : prompt (string), secret name
function make_secret()
{  
    if [[ $(podman secret inspect ${1} &>/dev/null; echo $?) == 0 ]]
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
            podman secret rm ${1}
             $(read -p "Enter variable for ${1} : " token) && printf token | podman secret create "${1}" -
        fi
    else
        $(read -p "Enter variable for ${1} : " token) && printf token | podman secret create "${1}" -
    fi

}

if [[ ${DEBUG} == "FALSE" ]]
then
    make_secret DUCKDNS_TOKEN
fi

make_secret MARIADB_ROOT_PASSWORD

# podman secret rm DB_PASSWORD &>/dev/null
# echo $db_password | podman secret create DB_PASSWORD -

### TEMPLATES

cat ${SCRIPTS_ROOT}/templates/env_files/scripts_env | envsubst > ${SCRIPTS_ROOT}/.env
cat ${SCRIPTS_ROOT}/templates/env_files/settings_env | envsubst > ${SCRIPTS_ROOT}/settings/settings_env
cat ${SCRIPTS_ROOT}/templates/settings/archive | envsubst > ${SCRIPTS_ROOT}/.archive
cat ${SCRIPTS_ROOT}/templates/django/manage.py | envsubst > ${CODE_PATH}/manage.py
cat ${SCRIPTS_ROOT}/templates/django/wsgi.py | envsubst > ${CODE_PATH}/${django_project_name}/wsgi.py
if [[ ${DEBUG} == "TRUE" ]]
then
    cat ${SCRIPTS_ROOT}/templates/gunicorn/gunicorn.conf.py | envsubst > ${SCRIPTS_ROOT}/settings/gunicorn.conf.py
    cat ${SCRIPTS_ROOT}/templates/gunicorn/supervisor_gunicorn | envsubst > ${SCRIPTS_ROOT}/settings/supervisor_gunicorn
    cat ${SCRIPTS_ROOT}/templates/swag/default | envsubst > ${SCRIPTS_ROOT}/dockerfiles/swag/default
fi
### Systemd system account creation


unset site_name
unset pod_name
unset base_dir
unset static_base_root
unset host_log_dir
unset swag_host_static_dir
unset secret_key
unset duckdns_token
unset duckdns_domain
unset tld_domain
unset db_name
unset db_user
unset db_password
unset email_app_address
unset email_app_key
unset email_from_address
unset custom_salt
unset recaptcha_public
unset recaptcha_private

${SCRIPTS_ROOT}/scripts/initial_provision.sh