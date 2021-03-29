#!/bin/bash

set -a
source .env
set +a

podman pod create --name $POD_NAME -p $PORT1_DESCRIPTION -p $PORT2_DESCRIPTION

./run_django_cont.sh
./run_duckdns_cont.sh
./run_clamd_cont.sh
./run_mariadb_cont.sh
./run_memcached_cont.sh
./run_elasticsearch_cont.sh

