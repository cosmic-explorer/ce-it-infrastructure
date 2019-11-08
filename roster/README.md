# CE COmanage Instance

These instructions are a guide for setting up the [COmanage
registry](https://spaces.at.internet2.edu/display/COmanage/) for the Cosmic
Explorer Consortium. They are not intended to be an exhausive guide to
COmanage, and assume that the user is familiar with the [COmanage registry
data model.](https://spaces.at.internet2.edu/display/COmanage/Registry+Data+Model)

## Install Instructions

To build and deploy COmanage, first download a copy of the
[comanage-registry-docker](https://github.com/Internet2/comanage-registry-docker/)
repository into this directory.  There are serveral outsiding pull requests
that are needed which have not yet been merged to master, so the `ce-it`
branch on the Cosmic Explorer
[fork](https://github.com/cosmic-explorer/comanage-registry-docker) of this
repository should be used until the patches are merged.  This can be obtained
by by running the commands
```sh
git clone git@github.com:cosmic-explorer/comanage-registry-docker.git
pushd comanage-registry-docker
git checkout -b ce-it origin/ce-it
popd
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

## Starting and Stopping the Containers

To start the containers, run
```sh
. comanage-env.sh
docker stack deploy --compose-file comanage-registry-stack.yml comanage-registry
```
and check the status with
```sh
docker stack ps --no-trunc comanage-registry
```
To stop the containers, run
```sh
docker stack rm comanage-registry
```

## Set up instructions

Once the registry is up and running, it is necessary to create the various
COUs, groups, and enrollment flows. 

### Registry Configuration

#### Configure access to Shibboleth attributes

`Platform` &rightarrow; `CMP Enrollment Configuration`

Enable `Enable Environment Attribute Retrieval`

`Given Name (Official)`: `name_GIVEN`
`Family Name (Official)`: `name_FAMILY`
`Email (Official)` : `mail`

`Save`

#### Create CO

`Platform` &rightarrow; `COs`

`Add CO`

`Name`: `CosmicExplorer` (note no spaces)
`Description` : `Cosmic Explorer` (spaces allowed)
`Status`: `Active`

`Add`

#### Set up unique identifier within CO

`Collaborations`  &rightarrow; `Cosmic Explorer`

`Configuration`  &rightarrow; `Extended Types`

`Add Extended Type`

`Name`: `cosid`
`Display Name`: `Cosmic Explorer ID`
`Status`: `Active`

`Configuration`  &rightarrow; `Identifier Assignments`

`Add Identifier Assignment`

`Description`: `Cosmic Explorer ID`
`Type`: `Cosmic Explorer ID`
`Email Type` : blank
`Login` : unchecked
`Algorith`: `Sequential`
`Format`: `COS(#)`
`Permitted Characters`: `AlphaNumeric Only`
`Minimum`: `1000000`
`Maximum`: blank

`Save`

#### Create COUs

`Configuration` &rightarrow; `COUs`

`Add a New COU`

`Name`: `PrincipalInvestigarors`
`Description`: `Cosmic Explorer PIs and coPIs`
`Parent COU`: `No COUs are available to be assigned parent`

`Add`

`Add a New COU`

`Name`: `CETeam`
`Description`: `Members of the Cosmic Explorer Team`
`Parent COU`: `PrincipalInvestigarors`

`Add`

`Add a New COU`

`Name`: `CEConsortium`
`Description`: `Cosmic Explorer Consortium`
`Parent COU`: `CETeam`

`Add`

#### Create Enrollment Flows

