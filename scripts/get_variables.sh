#!/bin/bash
set -a

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root" 
   exit 1
fi

echo -e "\nThe following questions are to fill out the env files that are called upon by the scripts when executing, and by the settings file during production.  The settings .env file is called from the settings file using os.getenv, after the env file is loaded into the environment by the python program dotenv.  This .env file is located in the settings folder, along with settings.py.  You can edit either of those files to edit your site.   Press enter to accept default value[] where listed...\n\n"

echo -e "#******************************************************************"
echo -e "#**** you must have downloaded django_artisan to a local dir  *****"
echo -e "#**** and have a password protected system user account       *****"
echo -e "#**** with a home directory ready                             *****"
echo -e "#******************************************************************"

read -p "Standard/service user account name ['artisan_sysd'] : " USER_NAME
USER_NAME=${USER_NAME:-"artisan_sysd"}
if [[ $(id ${USER_NAME} > /dev/null 2>&1; echo $?) -ne 0 ]]
then
    echo -e "Error, account with username ${USER_NAME} does not exist!"
    exit 1
# else
#     if [[ $(id -u ${USER_NAME}) -ge 1000 ]]
#     then
#         echo -e "Error, ${USER_NAME} account is not a system account"
#     fi
fi

read -p "Absolute path to User home dir [ /home/${USER_NAME} ] : " USER_DIR
USER_DIR=${USER_DIR:-/home/${USER_NAME}}

isValidVarName() {
    echo "$1" | grep -q '^[_[:alpha:]][_[:alpha:][:digit:]]*$' && return || return 1
}

until isValidVarName "${project_name}"
do
   read -p 'Artisan scripts project name - this is used as a directory name, so must be conformant to bash requirements : ' project_name
   if ! isValidVarName "${project_name}"
   then
       echo -e "That is not a valid variable name.  Your project name must conform to bash directory name standards"
   fi
done

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

echo -e "code path is ${CODE_PATH}"
popd &> /dev/null

PROJECT_NAME=${project_name}

PN=$(basename $(dirname $(find ${CODE_PATH} -name "asgi.py")))
read -p "Enter the name of the django project ie the folder in which wsgi.py resides [${PN}] : " django_project_name
django_project_name=${django_project_name:-${PN}}
DJANGO_PROJECT_NAME=$django_project_name

if [[ $(type Xorg > /dev/null 2>&1 | echo $?) -eq 0 ]]
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

dockerfile_app_names=""
if [[ ${DEBUG} == "TRUE" ]]
then
    echo -e 'mount app source code directories? - note that repository name must be indentical to the contained app name.'
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) MOUNT_SRC_CODE="TRUE"; break;;
            No ) MOUNT_SRC_CODE="FALSE"; break;;
        esac
    done
    if [[ ${MOUNT_SRC_CODE} == "TRUE" ]]
    then
        cd /
        until [[ -d "${SRC_CODE_PATH}" && ! -L "${SRC_CODE_PATH}" ]] 
        do
            echo -e 'mount source code directories (1) or mount git directories (2)'
            select sg in "src" "git"; do
                case $sg in
                    src ) MOUNT_GIT="FALSE"; break;;
                    git ) MOUNT_GIT="TRUE"; break;;
                esac
            done
            if [[ ${MOUNT_GIT} == "TRUE" ]]
            then
                SMSG='Symlinks will be to the git repository to allow you to use git submodules to track your code changes.'
            else
                SMSG='Symlinks will be to the source code directories inside the git repository.  You will have to manually track source code changes, updating each git in each repository.'
            fi
            echo -e 'Absolute path to git repository (the folder where your app directories reside) - *IMPORTANT* There must only be git repository directories at this path, ie each subdirectory of this path must be of the form "app_name" which must be a git repository for your app, and must have the subdirectory "app_name" containing the django_source_code.'
            echo -e ${SMSG}
            read -p ":" -e SRC_CODE_PATH
            if [[ ! -d "${SRC_CODE_PATH}" ]]
            then
               echo -e "That path doesn't exist!"
            fi
            if [[ -L "${SRC_CODE_PATH}" ]]
            then
                echo -e "Code path must not be a symbolic link"
            fi
        done
        dockerfile_app_names="RUN "
        for app_name in $(ls ${SRC_CODE_PATH});
        do 
            dockerfile_app_names="${dockerfile_app_names}mkdir -p /opt/${PROJECT_NAME}/${app_name}; "
        done
    fi
fi

cd ${SCRIPTS_ROOT}

if [[ ${DEBUG} == "TRUE" && $(id -u ${USER_NAME}) -lt 1000 ]]
then
    echo -e "      ** warning **\n\nIt is not reccommended to use a service account when using debug mode.\n  If you wish to continue, use ./artisan_run.sh output to display the output from the runserver command.\nAlternatively, and better still (more secure), use a standard user account.\n"
fi

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

## STATIC BASE ROOT AND MEDIA BASE ROOT
# static base root is in the container
if [[ ${DEBUG} == "TRUE" ]]
then
	SBR="/opt/${project_name}/"
else
	SBR="/etc/opt/${project_name}/static_files/"
fi
read -p "Static base root [${SBR}] : " sbr
static_base_root=${sbr:-${SBR}}

if [[ ${DEBUG} == "TRUE" ]]
then
    MBR="/opt/${project_name}/"
else
    MBR="/etc/opt/${project_name}/media_files/"
fi
read -p "Media base root [${MBR}] : " mbr
media_base_root=${mbr:-${MBR}}

## LOGS
read -p "Host log dir [${USER_DIR}/${project_name}/logs] : " hld
host_log_dir=${hld:-${USER_DIR}/${project_name}/logs}
read -p "Swag Host log dir (must be different to Host Log Dir) [${USER_DIR}/${project_name}/swag_logs] : " shld
swag_host_log_dir=${shld:-${USER_DIR}/${project_name}/swag_logs}
# host static dir mounts on to static base root from django and swag conts.

## HOST STATIC & MEDIA FOR VOLUME MOUNTS
host_static_dir=/etc/opt/${project_name}/static_files/
host_media_dir=/etc/opt/${project_name}/media_files/

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
db_vol_name="db_vol"
read -p "Host db volume name [ ${db_vol_name} ] : " dvn
db_vol_name=${dvn:-${db_vol_name}}

if [[ ${DEBUG} == "FALSE" ]]
then

read -p "Email address for letsencrypt certbot : " certbot_email

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

    swag_vol_name="cert_vol"
    read -p "Swag Volume Name [${swag_vol_name}] : " svn
    swag_vol_name=${svn:-${swag_vol_name}}
fi

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

read -p "Dropbox OAuth Token : " dropbox_oauth_token

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
    if [[ $(runuser --login ${USER_NAME} -c "podman secret inspect ${1} &>/dev/null"; echo $?) == 0 ]]
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
            runuser --login ${USER_NAME} -c "podman secret rm ${1}"
            read -p "Enter variable for ${1} : " token && echo -n "$token" | runuser --login "${USER_NAME}" -c "podman secret create \"${1}\" -" 
        fi
    else
        read -p "Enter variable for ${1} : " token && echo -n "$token" | runuser --login "${USER_NAME}" -c "podman secret create \"${1}\" -"
    fi
}

if [[ ${DEBUG} == "FALSE" ]]
then 
    make_secret DUCKDNSTOKEN
fi

make_secret MARIADB_ROOT_PASSWORD

runuser --login ${USER_NAME} -c "podman secret rm DB_PASSWORD"
echo -n $db_password | runuser --login "${USER_NAME}" -c "podman secret create \"DB_PASSWORD\" -"


# variables for create_directories.sh
echo PROJECT_NAME=${PROJECT_NAME} > .proj
echo USER_NAME=${USER_NAME} >> .proj
echo USER_DIR=${USER_DIR} >> .proj
echo SCRIPTS_ROOT=${SCRIPTS_ROOT} >> .proj
echo CODE_PATH=${CODE_PATH} >> .proj
echo SRC_CODE_PATH=${SRC_CODE_PATH} >> .proj
echo MOUNT_SRC_CODE=${MOUNT_SRC_CODE} >> .proj
echo MOUNT_GIT=${MOUNT_GIT} >> .proj
echo EXTRA_DOMAINS=${EXTRA_DOMAINS} >> .proj
echo DUCKDNS_SUBDOMAIN=${DUCKDNS_SUBDOMAIN} >> .proj
echo DB_NAME=${db_name} >> .proj
echo DB_USER=${db_user} >> .proj
echo DB_HOST=${db_host} >> .proj
echo DB_PASSWORD=${db_password} >> .proj
echo DEBUG=${DEBUG} >> .proj
echo XDESK=${XDESK} >> .proj
echo SWAG_VOL_NAME=${swag_vol_name} >> .proj
echo DB_VOL_NAME=${db_vol_name} >> .proj
echo CERTBOT_EMAIL=${certbot_email} >> .proj
echo DJANGO_HOST_STATIC_VOL=${host_static_dir} >> .proj
echo DJANGO_CONT_STATIC_VOL=${host_static_dir} >> .proj
echo DJANGO_HOST_MEDIA_VOL=${host_media_dir} >> .proj
echo DJANGO_CONT_MEDIA_VOL=${host_media_dir} >> .proj

### TEMPLATES
cat ${SCRIPTS_ROOT}/templates/dockerfiles/dockerfile_django_dev | envsubst '$dockerfile_app_names' > ${SCRIPTS_ROOT}/dockerfiles/dockerfile_django_dev
cat ${SCRIPTS_ROOT}/templates/env_files/scripts_env | envsubst > ${SCRIPTS_ROOT}/.env
cat ${SCRIPTS_ROOT}/templates/env_files/settings_env | envsubst > ${SCRIPTS_ROOT}/settings/settings_env
cat ${SCRIPTS_ROOT}/templates/settings/archive | envsubst > ${SCRIPTS_ROOT}/.archive
cat ${SCRIPTS_ROOT}/templates/django/manage.py | envsubst > ${CODE_PATH}/manage.py
chown ${USER_NAME}:${USER_NAME} ${CODE_PATH}/manage.py
cat ${SCRIPTS_ROOT}/templates/django/wsgi.py | envsubst > ${CODE_PATH}/${django_project_name}/wsgi.py
chown ${USER_NAME}:${USER_NAME} ${CODE_PATH}/${django_project_name}/wsgi.py
cat ${SCRIPTS_ROOT}/templates/gunicorn/init | envsubst > ${SCRIPTS_ROOT}/dockerfiles/django/init
if [[ ${DEBUG} == "TRUE" ]]
then
    cat ${SCRIPTS_ROOT}/templates/maria/maria_dev.sh | envsubst '$db_user:$db_host:$db_name' > ${SCRIPTS_ROOT}/dockerfiles/maria.sh
 else
    cat ${SCRIPTS_ROOT}/templates/maria/maria_prod.sh | envsubst '$db_user:$db_host:$db_name' > ${SCRIPTS_ROOT}/dockerfiles/maria.sh
fi

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

## automatic updates

echo -e "\nEnable container updates where possible ? : "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) updates="--label 'io.containers.autoupdate=registry'"; break;;
        No ) updates=""; break;;
    esac
done
### Systemd system account creation

unset site_name
unset pod_name
unset base_dir
unset static_base_root
unset media_base_root
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
