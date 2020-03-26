# Cosmic Explorer Mailman Instance

These instructions are a guide for setting up [GNU Mailman](https://www.list.org/) for the Cosmic
Explorer Consortium.

## Install Instructions

To build and deploy Mailman, first download a copy of the
[comanage-registry-docker](https://github.com/Internet2/comanage-registry-docker/)
repository into this directory.  There are serveral outsiding pull requests
that are needed which have not yet been merged to master so the Cosmic Explorer
[fork](https://github.com/cosmic-explorer/comanage-registry-docker) of this
repository should be used until the patches are merged.  This can be obtained
by by running the commands
```sh
git clone https://github.com/cosmic-explorer/comanage-registry-docker.git
```

Edit the file `mailman-env.sh` to set the environment variables to the appropriate values for the installation. The various 
`PASSWD` and `SECRET` variables should be set to real passwords generated, for example, by
```sh
export LC_CTYPE=C; cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

Run the build script by running the command
```sh
. build-mailman.sh
```

## Container Management

### Starting the Containers

Set up the envrionment by running
```sh
. mailman-env.sh
```

Start the [Let's Encrypt](https://letsencrypt.org) container with the command
```sh
docker-compose --file=letsencrypt.yml up --detach
```
and check the status of its output with
```sh
docker logs -f mail_letsencrypt_1
```
This container will obtain a host certificate signed by [Let's
Encrypt](https://letsencrypt.org) which will be used by the Mailman web
server. Once the certificate has been obtained, the logs will
contain the message
```
Server ready
```

Next start the back-end database with
```sh
docker-compose --file=mailman-database.yml up --detach
```
and check the status of its output witj
```sh
docker logs -f mail_database_1
```
Once the database is running, the logs will contain the message
```
LOG:  database system is ready to accept connections
```
