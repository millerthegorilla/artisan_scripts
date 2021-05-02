#!/bin/bash
echo -e "The following questions are to fill out the env files that are called upon by the scripts when executing, and by the settings file during production.  The settings .env file is called from the settings file using os.getenv, after the env file is loaded into the environment by the python program dotenv.  This .env file is located in the settings folder, along with settings.py.  You can edit either of those files to edit your site.   Press enter to accept default value[] where listed...\n\n"

set -a
project_name=${PROJECT_NAME}
echo -e "\n"

read -p "Enter the name of the django project ie the folder in which wsgi.py resides [${PROJECT_NAME}] : " django_project_name
django_project_name=${django_project_name:-${PROJECT_NAME}}

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

## DUCKDNS  -  used by duckdns container and swag
read -p "Duckdns token : " duckdns_token
read -p "Duckdns domain : " duckdns_domain

## SWAG ONLY DUCKDNS
read -p "Your top level domain that points at your duckdns domain : " tld_domain

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
set +a

cat ${SCRIPTS_ROOT}/templates/env_files/scripts_env | envsubst > ${SCRIPTS_ROOT}/.env
cat ${SCRIPTS_ROOT}/templates/env_files/settings_env | envsubst > ${SCRIPTS_ROOT}/settings/settings_env
cat ${SCRIPTS_ROOT}/templates/archive | envsubst > ${SCRIPTS_ROOT}/.archive
cat ${SCRIPTS_ROOT}/templates/manage.py | envsubst > ${CODE_PATH}/manage.py
cat ${SCRIPTS_ROOT}/templates/wsgi.py | envsubst > ${CODE_PATH}/${DJANGO_PROJECT_NAME}/wsgi.py
cat ${SCRIPTS_ROOT}/templates/gunicorn.conf.py | envsubst > ${SCRIPTS_ROOT}/settings/gunicorn.conf.py

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
