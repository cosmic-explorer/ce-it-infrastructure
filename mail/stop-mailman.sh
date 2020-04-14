#!/bin/bash -v

set -e

. mailman-env.sh

docker-compose --file=letsencrypt.yml down
docker-compose --file=mailman-database.yml down
docker-compose --file=mailman-postfix.yml down
docker-compose --file=mailman-web.yml down
docker-compose --file=mailman-apache.yml down

exit 0
