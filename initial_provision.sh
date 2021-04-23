podman image exists python:latest
if [[ ! $? -eq 0 ]]
then
	podman pull docker.io/library/python:latest &
fi
podman image exists elasticsearch:7.11.2
if [[ ! $? -eq 0 ]]
then
	podman pull docker.io/library/elasticsearch:7.11.2 &
fi
podman image exists mariadb:10.5.9
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/library/mariadb:10.5.9 &
fi
podman image exists memcached:1.6.9
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/library/memcached:1.6.9 &
fi
podman image exists docker-clamav:latest
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/mkodockx/docker-clamav:latest &
fi
podman image exists duckdns:latest
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/linuxserver/duckdns:latest &
fi
podman image exists swag:1.13.0-ls46
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/linuxserver/swag:version-1.14.0 &
fi

wait

podman image exists python:django
if [[ ! $? -eq 0 ]]
then
    if [[ -f "./.proj" ]]
    then
        source ./.proj
    fi
    
    echo -e "\n\n"
    read -p "Enter your project name - this is used as a directory name, so must be conformant to bash requirements [${PROJECT_NAME}] : " pn
    project_name=${pn:-${PROJECT_NAME}}
    
    echo -e "\n"
    
    read -p "Enter the absolute path to the directory where you have cloned django_artisan, ie where manage.py resides. [${CODE_PATH}] : " cp
    code_path=${cp:-${CODE_PATH}}
     
    echo -e "\n"
    set -a
    CODE_PATH=${code_path}
    PROJECT_NAME=${project_name}
    set +a
    
    cat ./templates/dockerfile_django | envsubst '${CODE_PATH} ${PROJECT_NAME}' > ./dockerfiles/dockerfile_django
    
    podman build --tag='python:django' -f='./dockerfiles/dockerfile_django'
fi

./create_all.sh
