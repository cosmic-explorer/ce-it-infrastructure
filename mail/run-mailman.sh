#!/bin/bash -v

set -e

. mailman-env.sh

docker-compose --file=letsencrypt.yml up --detach
docker-compose --file=mailman-database.yml up --detach
docker-compose --file=mailman-postfix.yml up --detach
docker-compose --file=mailman-web.yml up --detach
docker-compose --file=mailman-core.yml up --detach
docker-compose --file=mailman-apache.yml up --detach

exit 0
