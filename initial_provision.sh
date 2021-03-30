podman pull docker.io/library/python:latest
podman pull docker.io/library/elasticsearch:7.11.2
podman pull docker.io/library/mariadb:latest
podman pull docker.io/library/memcached:latest
podman pull docker.io/mkodockx/docker-clamav:latest
podman pull docker.io/linuxserver/duckdns:latest
podman pull docker.io/linuxserver/swag:latest
podman build --tag='python:django' -f='./dockerfiles/dockerfile_django'

./create_all.sh
