# Cosmic Explorer Document Control Center

Docker stack for running the Cosmic Explorer DCC.

The production stack depends Docker images for:
 - The DCC itself, which is created from `dcc-syr-disk0.qcow2` by `bootstrap-dcc.sh`
 - The [DCC REST
   API](https://github.com/cosmic-explorer/ce-it-infrastructure/tree/master/rest-dcc)
   which is published to
   [cosmicexplorer/rest-dcc](https://cloud.docker.com/u/cosmicexplorer/repository/docker/cosmicexplorer/rest-dcc)
   on Docker Hub.
 - A Cosmic Explorer implementation of the [User Login and Consent flow of ORY
   Hydra.](https://github.com/cosmic-explorer/hydra-login-consent-node/tree/dcc)
   This relies on the Shibboleth ePPN to do the authentication, and so it just
   passes the OAuth2 login and consent flow once Apache sees an approved ePPN.
   This image is published to [cosmicexplorer/hydra-login-consent-node](https://cloud.docker.com/u/cosmicexplorer/repository/docker/cosmicexplorer/hydra-login-consent-node) on Docker Hub.
 - The [ORY Hydra](https://github.com/ory/hydra) OAuth2 server.
 - The [Postgress](https://hub.docker.com/_/postgres) database for ORY Hydra
   and the [MariaDB](https://hub.docker.com/_/mariadb) database for the DCC.

All of the incomming connections are managed by the Apache server running in
the main DCC container, so only port 443 on that container needs to be open to
the outside world. All other network traffic is over the stack's internal
network.

## Setup

### Bootstrapping from a DCC image

Since the LIGO DCC source code is not yet on GitHub, we start from an image of
the DCC VM `dcc-syr-disk0.qcow2`. 

The bootstrap script migrates the database from the image to the path
specified by `STORAGE_PATH` and creates a database for use by the OAuth2
server.

First, customize the script `dcc-environment.sh` by setting the environment
variables to the appropriate values for your installation. The various 
`PASSWD` variables should be set to real passwords generated, for example, by
```sh
export LC_CTYPE=C; cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

To bootstrap the DCC, build the main container and the bootstrap continer by
running
```sh
yum -y install libguestfs-tools-c
export LIBGUESTFS_BACKEND=direct
. bootstrap-dcc.sh
```

The `bootstrap-dcc.sh` script uses a helper image that [implements a simple
npm wait-port
program](https://github.com/cosmic-explorer/ce-it-infrastructure/tree/master/wait-port)
and is published on Docker Hub at
[cosmicexplorer/wait-port](https://cloud.docker.com/u/cosmicexplorer/repository/docker/cosmicexplorer/wait-port).

The boostrap container can then be started with
```sh
docker-compose up --detach
```
The bootstrap container is not intended for production use. It runs
in a priveleged container and services are started using systemd that
configure the database.

Once the bootstrap container is running, log into it as root by running
```sh
docker exec -it dcc_dcc-bootstrap_1 /bin/bash -l
```
Once in the container run
```
watch -n 5 systemctl status
```
until the system state changes from `starting` to `running`. Once the system
is running, gracefully shut down the MariaDB database engine
with
```sh
systemctl stop mariadb.service
```
Then log out of the bootstrap container and stop it with
```sh
docker-compose down
```
Remove the temporary certificates directory with the command
```sh
rm -rf ${CERT_DIR}
```

## Running the DCC in production

To run the DCC as a Docker stack in production, run the script
```sh
. run-dcc.sh
```

Start the [Let's Encrypt](https://letsencrypt.org) container with the command
```sh
docker-compose --file=letsencrypt.yml up --detach
```
and check the status of its output with
```sh
docker logs -f dcc_letsencrypt_1
```
This container will obtain a host certificate signed by [Let's
Encrypt](https://letsencrypt.org) which will be used by the COmanage web
server and LDAP server. Once the certificate has been obtained, the logs will
contain the message
```
Server ready
```

<!--
When the script is complete, it shows the following message as the containers
boot:
```
Creating network dcc_default
Creating service dcc_rest-api
Creating service dcc_oauth-database
Creating service dcc_oauth-server
Creating service dcc_oauth-consent
Creating service dcc_dcc
Creating service dcc_letsencrypt
Creating service dcc_docdb-database
```
The `dcc_dcc` container is not initially deployed, as it needs the
certificates obtained by the Let's Encrypt container. Monitor this container's
status with the command
```sh
docker service logs -f dcc_letsencrypt
```
until the logs file show the message
```
Server ready
```
-->

Once the certificates have been obtained, start the DCC services with the commands
```sh
docker-compose --file=dcc-backend.yml up --detach
docker-compose --file dcc-apache.yml up --detach
```

<!--
Once the certificates have been obtained, start the main DCC container with the command
```sh
docker service scale dcc_dcc=1
```
It takes some time for the DCC to boot (primarily the time shibd takes to
validate the InCommon service provider metadata). You can check the status
of the machines with
```sh
docker stack ps --no-trunc dcc
```
-->

## Monitoring status

### DCC database container

The log of the DCC database container can be checked with
```sh
docker service logs -f dcc_docdb-database
```
If the database started successfully, the log will contain the messages
```
[Note] mysqld: ready for connections.
Version: '10.2.27-MariaDB-1:10.2.27+maria~bionic'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  mariadb.org binary distribution
```
The error messages about `Could not find target log during relay log
initialization` and `Failed to initialize the master info structure` can be
ignored as we are not using database replication.

### OAuth2 database container
The log of the OAuth2 database container can be checked with
```sh
docker service logs -f dcc_oauth-database
```
If the database started successfully, the log will contain the messages
```
LOG:  database system is ready to accept connections
```

### OAuth server container

The log of the OAuth2 database container can be checked with
```sh
docker service logs -f dcc_oauth-server
```
If the OAuth2 server started successfully, the log will contain the messages
```
Setting up http server on :4445
Setting up http server on :4444
```

### REST API container

The log of the REST API container can be checked with
```sh
docker service logs -f dcc_rest-api
```
If the REST API started successfully, the log will contain the messages
```
Executing (default): SELECT 1+1 AS result
Listening on port 8443
```
If the REST API container came up before the database container, you may see
the message `ConnectionError: The address 'docdb-database' cannot be found`.
This can be ignores, as long as the `Listening on port 8443` is eventually
shown.

### DCC web server container

The log of the main DCC web server container can be checked with
```sh
docker service logs -f dcc_dcc
```
If the DCC started successfully, the log will contain the messages
```
INFO success: cron entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
INFO success: shibd entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
INFO success: apache2 entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
```
It can take several minutes for shibd to validate the InCommon service
certifiates. When this is complete, the DCC will be available to accept
connections.

## Shutting Down and Restarting the DCC

The system can be stopped with
```sh
docker stack rm dcc
```
and started with
```sh
. dcc-envrionment.sh
docker stack deploy --compose-file dcc.yml dcc
docker service scale dcc_dcc=1
```
