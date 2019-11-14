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
git clone git@github.com:cosmic-explorer/comanage-registry-docker.git
```
After cloning this repository, run the build script by running the command
```sh
. build-comanage.sh
```

One the containers are built and configured, start the stack with the command
```sh
docker stack deploy --compose-file comanage-registry-stack.yml comanage-registry
```

### Additional mail configuration

The first time that the stack is run, you wull need to edit the file `/srv/docker/comanage/srv/comanage-registry/local/Config/email.php` and remove the lines
```php
    'username' => 'account@gmail.com',
    'password' => 'password'
```
as well as the `,` on the preceeding line, since the Syracuse SMTP host use
IP-based authorization rather than username/password authentication.

### Additional Shibboleth configuration

The `build-comanage.sh` script is configured to inherit the Shibboleth
configuration of the host machine, which is copied into
`/srv/docker/comanage/etc/shibboleth` on the host and then used by the
container. Our default Shibboleth attribute map maps the user's given 
name and surname to two different variables. [COmanage wants these to be
stored](https://spaces.at.internet2.edu/display/COmanage/Consuming+External+Attributes+via+Web+Server+Environment+Variables#ConsumingExternalAttributesviaWebServerEnvironmentVariables-PopulatingDefaultValuesDuringEnrollment)
in variables with a common string and the suffixes `_GIVEN` and `_FAMILY`.
To do this, edit the file `/srv/docker/comanage/etc/shibboleth/attribute-map.xml` 
on the host machine and remove any lines from the `<Attributes>` section of the file that reference `urn:oid:2.5.4.42` and `urn:oid:2.5.4.4`. Then add the lines:
```
    <Attribute name="urn:oid:2.5.4.42" id="name_GIVEN"/>
    <Attribute name="urn:oid:2.5.4.4" id="name_FAMILY" />
```
and save the file. Since Shibboleth can't be restarted
from within the COmanage registry container, you will need to stop and restart
the containers.

## Containers Management

### Starting the Containers

To start the containers, run
```sh
. comanage-env.sh
docker stack deploy --compose-file comanage-registry-stack.yml comanage-registry
```
Once the stack has been deployed, check the status of the [linuxserver/letsencrypt](https://hub.docker.com/r/linuxserver/letsencrypt/) container by running the command
```sh
docker service logs -f comanage-registry_letsencrypt
```
This container will obtain a host certificate signed by [Let's
Encrypt](https://letsencrypt.org) which will be used by the COmanage web
server and LDAP server. Once the certificate has been obtained, the logs will
contain the message
```
Server ready
```
The registry and LDAP containers can then be started with the command
```sh
docker service scale comanage-registry_comanage-registry-ldap=1
docker service scale comanage-registry_comanage-registry=1
```

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

## Registry Configuration

Once the registry is up and running, it is necessary to create the various
COUs, groups, and enrollment flows. The registry configuration depends on how
you want to use COmanage. The document [Cosmic Explorer COmanage
Deployment](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/roster/doc/README.md)
walks through the specific setup that Cosmic Explorer uses.
