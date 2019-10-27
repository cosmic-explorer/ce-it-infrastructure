# Cosmic Explorer Document Control Center

Docker stack for running the Cosmic Explorer DCC.

## Setup

### Bootstrapping from a DCC image

Since the LIGO DCC source code is not yet on GitHub, we start from an image of
the DCC VM `dcc-syr-disk0.qcow2`. 

The bootstrap script migrates the database from the image to the path
specified by `STORAGE_PATH` and creates a database for use by the OAuth2
server.

First, customize the script `bootstrap-dcc.sh` by setting the environment
variables at the top of the script to the appropriate vales for your
installation:
```sh
export STORAGE_PATH=/srv/docker/dcc
export DCC_INSTANCE=seaview.phy.syr.edu
export DCC_HOSTNAME=seaview.phy.syr.edu
export DCC_DOMAINNAME=phy.syr.edu
export MYSQL_ROOT_PASSWD=badgers
export MYSQL_DOCDBRW_PASSWD=mushroommushroom
export MYSQL_DOCDBRO_PASSWD=badgersbadgersbadgers
export HYDRA_PASSWD=aghitsasnake
```
The various `PASSWD` variables should be set to real passwords. 
You may find this [password generator](https://www.youtube.com/embed/EIyixC9NsLI?autoplay=1)
helpful to create secure passwords.


To bootstrap the DCC, build the main container and the bootstrap continer by
running
```sh
. bootstrap-dcc.sh
```
You will need to make a note of the `SECRETS_SYSTEM` and the `DCC_REST_SECRET`
strings as they is needed to start the OAuth2 server in production.

The boostrap container can then be started with
```sh
docker-compose up --detach
```
Although the bootstrap container is a functional DCC instance, is not intended
for production use as it runs in a priveleged container and services are
started using systemd. Once the bootstrap container is running, log into it as
root by running
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

## Running the DCC in production

The production stack depends on the [DCC REST
API](https://github.com/cosmic-explorer/ce-it-infrastructure/rest-dcc) so before deploying the
stack, make sure that the image `cosmicexplorer/rest-dcc` is available.

Set the environment variable `SECRETS_SYSTEM` to the value of the OAuth2
server secret created above.

To run the DCC as a Docker stack in production, run the script
```sh
. run-dcc.sh
```
It takes some time for the images to boot (primarily the time for shibd to
validate the InCommon service provider metadata). You can check the status
of the machines with
```sh
docker stack ps --no-trunc dcc
```

## Monitoring status

### DCC database container

The log of the DCC database container can be checked with
```sh
docker service logs dcc_docdb-database
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
docker service logs dcc_oauth-database
```
If the database started successfully, the log will contain the messages
```
LOG:  database system is ready to accept connections
```

### OAuth server container

The log of the OAuth2 database container can be checked with
```sh
docker service logs dcc_oauth-server
```
If the OAuth2 server started successfully, the log will contain the messages
```
Setting up http server on :4445
Setting up http server on :4444
```
You can also test to see if tokens can be issued and validated. To issue a
token, run
```sh
docker run --rm -it \
   --network dcc_default \
   oryd/hydra:v1.0.8 \
   token client \
     --client-id dcc-rest-api \
     --client-secret ${DCC_REST_SECRET} \
     --endpoint http://dcc_oauth-server:4444
```
This should return an OAuth token that looks like
```
5_avf_XmTQC5YbHKmv5j_PvFmCfwfeiQvs6t9Zs5W0M.EJB_SmXm28XLkNIyMQOij-F2AsCnDtv6jWdP_afL2ho
```
Validate this token by running
```sh
docker run --rm -it \
  --network dcc_default \
  oryd/hydra:v1.0.8 \
  token introspect \
    --client-id dcc-rest-api \
    --client-secret ${DCC_REST_SECRET} \
    --endpoint http://dcc_oauth-server:4445 \
    >INSERT-TOKEN-HERE<
```
This should return JSON that looks like
```json
{
	"active": true,
	"aud": null,
	"client_id": "dcc-rest-api",
	"exp": 1572210609,
	"iat": 1572207009,
	"iss": "http://127.0.0.1:9000/",
	"sub": "dcc-rest-api",
	"token_type": "access_token"
}
```
If this contains `"active": true` and `"token_type": "access_token"` then the
token is valid.

### REST API container

The log of the REST API container can be checked with
```sh
docker service logs dcc_rest-api
```
If the REST API started successfully, the log will contain the messages
```
Executing (default): SELECT 1+1 AS result
Listening on port 8443
```

### DCC web server container

The log of the main DCC web server container can be checked with
```sh
docker service logs dcc_dcc
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

## Shutting down the DCC

The system can be stopped with
```sh
docker stack rm dcc
```
