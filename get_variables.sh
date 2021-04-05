#!/bin/bash
echo -e "The following questions are to fill out the env files that are called upon by the scripts when executing, and by the settings file during production.  The settings .env file is called from the settings file using os.getenv, after the env file is loaded into the environment by the python program dotenv.  This .env file is located in the settings folder, along with settings.py.  You can edit either of those files to edit your site.   Press enter to accept default value[] where listed...

echo -e "Enter your...."
read -p "Project name: " project_name
read -p "Site name (as used in the website header/logo: " site_name
pod_name = ${project_name}_pod
read -p "Pod name [${pod_name}] : " pname
pod_name=${pname:-${pod_name}}
read -p "Base code directory [/opt/${project_name}/] : " bdir
base_dir=${bdir:-/opt/${project_name}/}
read -p "Static base root [/etc/opt/${project_name}/static_files] : " sbr
static_base_root=${sbr:-/etc/opt/${project_name}/static_files}
read -p "Host log dir [${HOME}/${project_name}/logs/ : " hld
host_log_dir=${hld:-${HOME}/${project_name}/logs/}
swag_host_static_dir=${static_base_root}
secret_key=$(tr -dc 'a-z0-9!@#$%^&*(-_=+)' < /dev/urandom | head -c50)
read -p "Duckdns token : " duckdns_token
read -p "Duckdns domain : " duckdns_domain
read -p "Your top level domain that points at your duckdns domain : " tld_domain
read -p "Your django database name : " db_name
read -p "Your django database username : " db_user
db_password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
echo -e "#************* email settings ***************"
echo -e "# https://support.google.com/accounts/answer/185833?hl=en"
echo -e "#********************************************"
read -p "Your app email server address : " email_app_address
read -p "Your app email server address secret password : " email_app_key
read -p "Your app email from address ie ( no_reply@${project_name}.org ): email_from_address
custom_salt=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
echo -e "#************* Google recaptcha settings ***************"
echo -e "# https://developers.google.com/recaptcha/intro "
echo -e "#*****************************************************"
read -p "Google Recaptcha public key : " recaptcha_public
read -p "Google Recaptcha private key : " recaptcha_private

cat ${SCRIPTS_ROOT}/templates/env_files/scripts_env | envsubst > ${SCRIPTS_ROOT}/env_files/scripts_env
cat ${SCRIPTS_ROOT}/templates/env_files/settings_env | envsubst > ${SCRIPTS_ROOT}/env_files/settings_env