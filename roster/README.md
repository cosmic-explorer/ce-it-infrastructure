# Cosmic Explorer COmanage Registry

These instructions are a guide for setting up the [COmanage
registry](https://spaces.at.internet2.edu/display/COmanage/) for the Cosmic
Explorer Consortium. They are not intended to be an exhausive guide to
COmanage, and assume that the user is familiar with the [COmanage registry
data model.](https://spaces.at.internet2.edu/display/COmanage/Registry+Data+Model)

## Install Instructions

To build and deploy COmanage, first download a copy of the
[comanage-registry-docker](https://github.com/Internet2/comanage-registry-docker/)
repository into this directory.  There are serveral outsiding pull requests
that are needed which have not yet been merged to master so the Cosmic Explorer
[fork](https://github.com/cosmic-explorer/comanage-registry-docker) of this
repository should be used until the patches are merged.  This can be obtained
by by running the commands
```sh
git clone https://github.com/cosmic-explorer/comanage-registry-docker.git
```

Edit the file `comanage-env.sh` to set the environment variables to the appropriate values for the installation. The various 
`PASSWD` variables should be set to real passwords generated, for example, by
```sh
export LC_CTYPE=C; cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

Run the build script by running the command
```sh
. build-comanage.sh
```

## Container Management

### Starting the Containers

Set up the envrionment by running
```sh
. comanage-env.sh
```

<!--
To start the containers, run
```sh
. comanage-env.sh
docker stack deploy --compose-file comanage-registry-stack.yml comanage-registry
```
Once the stack has been deployed, check the status of the [linuxserver/letsencrypt](https://hub.docker.com/r/linuxserver/letsencrypt/) container by running the command
```sh
docker service logs -f comanage-registry_letsencrypt
```
-->

Start the [Let's Encrypt](https://letsencrypt.org) container with the command
```sh
docker-compose --file=letsencrypt.yml up --detach
```
and check the status of its output with
```sh
docker logs -f roster_letsencrypt_1
```
This container will obtain a host certificate signed by [Let's
Encrypt](https://letsencrypt.org) which will be used by the COmanage web
server and LDAP server. Once the certificate has been obtained, the logs will
contain the message
```
Server ready
```
The database container can be started with
```sh
docker-compose --file=comanage-database.yml up --detach
```
and its logs checked with
```sh
docker logs -f roster_comanage-registry-database_1
```
Once the database says
```
mysqld: ready for connections.
```
then the registry container can be started with
```sh
docker-compose --file=comanage.yml up --detach
```
and the container status checked with
```sh
docker logs -f roster_comanage-registry_1
```

<!--
The registry and LDAP containers can then be started with the command
```sh
docker service scale comanage-registry_comanage-registry-ldap=1
docker service scale comanage-registry_comanage-registry=1
```
-->

### Additional mail configuration

The first time that the stack is run, you wull need to edit the file `/srv/docker/comanage/srv/comanage-registry/local/Config/email.php` and remove the lines
```php
    'username' => 'account@gmail.com',
    'password' => 'password'
```
as well as the `,` on the preceeding line, since the Syracuse SMTP host uses
IP-based authorization, rather than username/password authentication.

<!--
### Checking Container Status

You can check the status with
```sh
docker stack ps --no-trunc comanage-registry
```

### Stopping the Containers

To stop the containers, run
```sh
docker stack rm comanage-registry
```
-->

### Stopping the Containers

To stop the containers, run
```sh
docker-compose --file=comanage.yml down
docker-compose --file=comanage-database.yml down
docker-compose --file=letsencrypt.yml down
```

## Registry Configuration

Once the registry is up and running, it is necessary to create the various
COUs, groups, and enrollment flows. The registry configuration depends on how
you want to use COmanage. The document [Cosmic Explorer COmanage
Deployment](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/roster/doc/README.md)
walks through the specific setup that Cosmic Explorer uses.
