podman image exists python:latest
if [[ ! $? -eq 0 ]]
then
	podman pull docker.io/library/python:latest
fi
podman image exists elasticsearch:7.11.2
if [[ ! $? -eq 0 ]]
then
	podman pull docker.io/library/elasticsearch:7.11.2
fi
podman image exists mariadb:latest
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/library/mariadb:latest
fi
podman image exists memcached:latest
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/library/memcached:latest
fi
podman image exists docker-clamav:latest
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/mkodockx/docker-clamav:latest
fi
podman image exists duckdns:latest
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/linuxserver/duckdns:latest
fi
podman image exists swag:latest
if [[ ! $? -eq 0 ]]
then
        podman pull docker.io/linuxserver/swag:latest
fi
podman image exists python:django
if [[ ! $? -eq 0 ]]
then
    if [[ -f "./.proj" ]]
    then
        project_name=$(cat ./.proj)
        pname=[${project_name}]
    else
        pname=""
    fi

    read -p "Enter your project name - this is used as a directory name, so must be conformant to bash requirements ${pname} : " pn

    project_name=${pn:-${project_name}}

    set -a
    PROJECT_NAME=${project_name}
    set +a
    podman build --tag='python:django' -f='./dockerfiles/dockerfile_django'
fi

./create_all.sh
