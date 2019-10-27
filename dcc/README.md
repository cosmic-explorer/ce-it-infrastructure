# Cosmic Explorer Document Control Center

Docker stack for running the Cosmic Explorer DCC.

## Bootstrapping from an existing image

Since the LIGO DCC source code is not yet on GitHub, we start from an image of
the DCC VM `dcc-syr-disk0.qcow2`. 

First, customize the script `bootstrap-dcc.sh` by setting the environment
variables at the top of the script to the appropriate vales for your
installation:
```sh
export STORAGE_PATH=/srv/docker/dcc
export DCC_INSTANCE=seaview.phy.syr.edu
export DCC_HOSTNAME=seaview.phy.syr.edu
export DCC_DOMAINNAME=phy.syr.edu
export MYSQL_ROOT_PASSWD=badgers
export MYSQL_DOCDBRW_PASSWD=herecomethebadgers
export MYSQL_DOCDBRO_PASSWD=badgersbadgersbadgers
```
To bootstrap the DCC, build the main container and the bootstrap continer by
running
```sh
. bootstrap-dcc.sh
```
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
is running, gracefully shut down the MariaDB database engine with
```sh
systemctl stop mariadb.service
```
Then log out of the bootstrap container and stop it with
```
docker-compose down
```
You can remove the bootstrap image at this point with
```sh
docker image rm cosmicexplorer/dcc-bootstrap
```
## Running the DCC in production

The production stack depends on the [DCC REST
API](https://github.com/cosmic-explorer/rest-dcc) so before deploying the
stack, make sure that the image `cosmicexplorer/rest-dcc` is available.

To run the DCC as a Docker stack in production, run the script
```sh
. run-dcc.sh
```
It takes some time for the images to boot (primarily the time for shibd to
validate the InCommon service provider metadata). You can check the status
of the machines with
```sh
docker stack ps dcc
```

## Monitoring status

### Database container

The log of the database container can be checked with
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
