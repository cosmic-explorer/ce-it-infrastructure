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
The logs can be checked with `docker service logs <container>`.

## Shutting down the DCC

The system can be stopped with
```sh
docker stack rm dcc
```
