# Cosmic Explorer IT Infrastructure

This repository contains the resources and documentation necessary to set up
the collaboration cyberinfrastructure used by Cosmic Explorer. We deploy four
primary services:

 * An instance of [COmanage Registry](https://www.internet2.edu/products-services/trust-identity/comanage/) to allow people to sign up to Cosmic Explorer and for the provisioning of associated services.
 * An instance of the [DocDB document server](http://docdb-v.sourceforge.net/) based on the fork used by the [LIGO Document Control Center](https://dcc.ligo.org/) to manage the storage and retrieval of documents.
 * A [GNU Mailman](https://list.org/) instance for mailing lists.
 * Integration with the [cosmic-explorer](https://github.com/cosmic-explorer) organization on [GitHub](https://github.com/) for collaborative repository management.
 * A [Shibboleth Identity Provider](https://www.shibboleth.net/products/identity-provider/) that acts as an ORCiD to SAML gateway for providing user identities.

This repository contains instructions for:

 * [Installing COmanage](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/roster) and [setting up the registry.](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/roster/doc)
 * [Installing and running an instance of the DCC.](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/dcc)
 * [Installing and configuring Mailman.](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/mail)
 * [Configuring the Shibboleth IdP.](https://github.com/duncan-brown/ce-it-infrastructure/tree/master/idp)

The repository provides two tools used by the services:

 * An implementation of a [RESTful API to the DCC DocDB Database](https://github.com/cosmic-explorer/ce-it-infrastructure/tree/master/rest-dcc) that allows COmanage to provision authors and groups in the DCC.
 * A helper container to determine when a [port is open](https://github.com/cosmic-explorer/ce-it-infrastructure/tree/master/wait-port) from inside a Docker container network.

The infrastructure also relies on the following repositories hosted by the [cosmic-explorer](https://github.com/cosmic-explorer) GitHub organization:

 * A fork of [COmanage Regustry](https://github.com/cosmic-explorer/comanage-registry) that contains the source for the fixed GitHub provisioner and the DCC provisioner until these are merged into the main COmanage repository.
 * A fork of the [Hydra Login and Consent Node](https://github.com/cosmic-explorer/hydra-login-consent-node) used by the DCC to perform OAuth2 delegation of credentials to COmanage. This is essentially the same as the original version, but removes the `foo@bar.com` login as authentication is managed by Apache Shibboleth which reverse proxies to the consent node.
 * A fork of [the COmanage registry docker containers](https://github.com/cosmic-explorer/comanage-registry-docker) to allow us to make any CE specific changes. Currently this is even with the upstream repository as no patches are needed.

The infrastructure also relies on the following externally provided infrastructure:

 * The [Linux Server implementation](https://github.com/linuxserver/docker-letsencrypt) of [Let's Encrypt](https://letsencrypt.org/) to obtain host certificates run from a [Docker container.](https://hub.docker.com/r/linuxserver/letsencrypt/)
 * The [Ory Hydra OAuth2 Server](https://github.com/ory/hydra) used to secure the [RESTful interface to the DCC.](https://github.com/cosmic-explorer/ce-it-infrastructure/tree/master/rest-dcc)
 * Docker containers for [Postgress](https://hub.docker.com/_/postgres) and [MariaDB](https://hub.docker.com/_/mariadb) for database support.

## Server Setup

To create and deploy these services, we use a single VMware host machine `ce-services.phy.syr.edu` that contains three additional virtual NICs for the services that we will deploy:

 * `roster.cosmicexplorer.org`, an alias to `128.230.146.12`, internally known as `ce-roster.phy.syr.edu`.
 * `dcc.cosmicexplorer.org`, an alias to `128.230.146.13`, internally known as `ce-dcc.phy.syr.edu`.
 * `mail.cosmicexplorer.org`, an alias to `128.230.146.15`, internally known as `ce-mail.phy.syr.edu`.

The services themselves are run inside Docker containers on the machines listed above.

First [set up the host networking](https://github.com/cosmic-explorer/ce-it-infrastructure/blob/master/etc/README.md) to configure the multiple NICs to route to the `128.230.146.0` subnet correctly.

## Shibboleth Setup

These services should be federated as [Shibboleth](https://www.internet2.edu/products-services/trust-identity/shibboleth/) Service Providers with [InCommon Research and Scholarship ](https://www.incommon.org/federation/research-and-scholarship/) and have appropriate host certificates and [Shibboleth metadata](https://spaces.at.internet2.edu/display/InCFederation/Research+and+Scholarship+for+SPs) prior to configuring them.

The [sugwg/apache-shibd](https://github.com/sugwg/apache-shibd) Docker container can be used to create the Shibboleth metadata for federation to incommon. To do this, first obtain InCommon host certificates for each interface.

To create the Shibboleth metadata, run the commands below for each interface. First, make a directory for each interface
```
mkdir -p ce-mail ce-roster ce-dcc
```
and perform in the apache shibd configuration step in each directory.

### COmanage

The default Shibboleth attribute map maps the user's given 
name and surname to two the variables `givenName` and `sn`. [COmanage wants these to be
stored](https://spaces.at.internet2.edu/display/COmanage/Consuming+External+Attributes+via+Web+Server+Environment+Variables#ConsumingExternalAttributesviaWebServerEnvironmentVariables-PopulatingDefaultValuesDuringEnrollment)
in variables with a common string (we use `name`) with the suffixes `_GIVEN` and `_FAMILY`.
This set up adds the `<Attribute Resolver>` elements needed to create these.

```sh
git clone https://github.com/sugwg/apache-shibd.git
cd apache-shibd/certificates
./keygen.sh
cd ..
cp /path/to/certs/ce-roster_phy_syr_edu_cert.cer certificates/hostcert.pem
cp /path/to/certs/ce-roster.phy.syr.edu.key certificates/hostkey.pem
cat >> assertion-consumer-service.xml <<EOF
	       <EndpointBase>https://roster.cosmicexplorer.org/Shibboleth.sso</EndpointBase>
           <EndpointBase>https://ce-roster.phy.syr.edu/Shibboleth.sso</EndpointBase>
EOF
cat >> provider-metadata.xml <<EOF
	<MetadataProvider type="XML" url="https://sugwg-ds.phy.syr.edu/sugwg-orcid-metadata.xml"
        backingFilePath="/var/log/shibboleth/sugwg-orcid-metadata.xml" reloadInterval="82800" legacyOrgNames="true"/>

        <AttributeResolver type="Template" sources="givenName" dest="name_GIVEN">
            <Template>\$givenName</Template>
        </AttributeResolver>
        <AttributeResolver type="Template" sources="sn" dest="name_FAMILY">
            <Template>\$sn</Template>
        </AttributeResolver>
EOF
docker build \
    --build-arg SHIBBOLETH_SP_ENTITY_ID=http://ce-roster.phy.syr.edu/shibboleth-sp \
    --build-arg SHIBBOLETH_SP_SAMLDS_URL=https://dcc.cosmicexplorer.org/shibboleth-ds/index.html \
    --build-arg SP_MD_SERVICENAME="Syracuse University Gravitational Wave Group - CE COmanage" \
    --build-arg SP_MD_SERVICEDESCRIPTION="Cosmic Explorer COmanage Roster" \
    --build-arg SP_MDUI_DISPLAYNAME="Syracuse University Gravitational Wave Group - CE COmanage" \
    --build-arg SP_MDUI_DESCRIPTION="Cosmic Explorer COmanage Roster" \
    --build-arg SP_MDUI_INFORMATIONURL="https://cosmicexplorer.org" \
    --rm -t cosmicexplorer/apache-shibd-roster .
    
docker network create --attachable \
    --opt 'com.docker.network.bridge.name=bridge-roster' \
    --opt 'com.docker.network.bridge.enable_ip_masquerade=false' \
    bridge-roster
    
docker run --name=apache-shibd-roster --rm -d \
    --network=bridge-roster \
    --hostname ce-roster.phy.syr.edu \
    --domainname phy.syr.edu \
    -v `pwd`/shibboleth:/mnt \
    cosmicexplorer/apache-shibd-roster:latest
```

### DCC

```sh
git clone https://github.com/sugwg/apache-shibd.git
cd apache-shibd/certificates
./keygen.sh
cd ..
cp /path/to/certs/ce-roster_phy_syr_edu_cert.cer certificates/hostcert.pem
cp /path/to/certs/ce-roster.phy.syr.edu.key certificates/hostkey.pem
cat >> assertion-consumer-service.xml <<EOF
	       <EndpointBase>https://dcc.cosmicexplorer.org/Shibboleth.sso</EndpointBase>
           <EndpointBase>https://ce-dcc.phy.syr.edu/Shibboleth.sso</EndpointBase>
EOF
cat >> provider-metadata.xml <<EOF
	<MetadataProvider type="XML" url="https://sugwg-ds.phy.syr.edu/sugwg-orcid-metadata.xml"
        backingFilePath="/var/log/shibboleth/sugwg-orcid-metadata.xml" reloadInterval="82800" legacyOrgNames="true"/>
EOF
docker build \
    --build-arg SHIBBOLETH_SP_ENTITY_ID=http://ce-dcc.phy.syr.edu/shibboleth-sp \
    --build-arg SHIBBOLETH_SP_SAMLDS_URL=https://dcc.cosmicexplorer.org/shibboleth-ds/index.html \
    --build-arg SP_MD_SERVICENAME="Syracuse University Gravitational Wave Group - CE DCC" \
    --build-arg SP_MD_SERVICEDESCRIPTION="Cosmic Explorer DCC" \
    --build-arg SP_MDUI_DISPLAYNAME="Syracuse University Gravitational Wave Group - CE DCC" \
    --build-arg SP_MDUI_DESCRIPTION="Cosmic Explorer DCC" \
    --build-arg SP_MDUI_INFORMATIONURL="https://cosmicexplorer.org" \
    --rm -t cosmicexplorer/apache-shibd-dcc .
    
docker network create --attachable \
    --opt 'com.docker.network.bridge.name=bridge-dcc' \
    --opt 'com.docker.network.bridge.enable_ip_masquerade=false' \
    bridge-dcc
    
docker run --name=apache-shibd-dcc --rm -d \
    --network=bridge-dcc \
    --hostname ce-dcc.phy.syr.edu \
    --domainname phy.syr.edu \
    -v `pwd`/shibboleth:/mnt \
    cosmicexplorer/apache-shibd-dcc:latest
```

### Mailman

```sh
git clone https://github.com/sugwg/apache-shibd.git
cd apache-shibd/certificates
./keygen.sh
cd ..
cp /path/to/certs/ce-roster_phy_syr_edu_cert.cer certificates/hostcert.pem
cp /path/to/certs/ce-roster.phy.syr.edu.key certificates/hostkey.pem
cat >> assertion-consumer-service.xml <<EOF
           <EndpointBase>https://mail.cosmicexplorer.org/Shibboleth.sso</EndpointBase>
           <EndpointBase>https://ce-mail.phy.syr.edu/Shibboleth.sso</EndpointBase>
EOF
cat >> provider-metadata.xml <<EOF
	<MetadataProvider type="XML" url="https://sugwg-ds.phy.syr.edu/sugwg-orcid-metadata.xml"
        backingFilePath="/var/log/shibboleth/sugwg-orcid-metadata.xml" reloadInterval="82800" legacyOrgNames="true"/>
EOF
docker build \
    --build-arg SHIBBOLETH_SP_ENTITY_ID=http://ce-mailman.phy.syr.edu/shibboleth-sp \
    --build-arg SHIBBOLETH_SP_SAMLDS_URL=https://dcc.cosmicexplorer.org/shibboleth-ds/index.html \
    --build-arg SP_MD_SERVICENAME="Syracuse University Gravitational Wave Group - CE Mailman" \
    --build-arg SP_MD_SERVICEDESCRIPTION="Cosmic Explorer Mailman Server" \
    --build-arg SP_MDUI_DISPLAYNAME="Syracuse University Gravitational Wave Group - CE Mailman" \
    --build-arg SP_MDUI_DESCRIPTION="Cosmic Explorer Mailman Server" \
    --build-arg SP_MDUI_INFORMATIONURL="https://cosmicexplorer.org" \
    --rm -t cosmicexplorer/apache-shibd-mail .
    
docker network create --attachable \
    --opt 'com.docker.network.bridge.name=bridge-mail' \
    --opt 'com.docker.network.bridge.enable_ip_masquerade=false' \
    bridge-mail
    
docker run --name=apache-shibd-mail --rm -d \
    --network=bridge-mail \
    --hostname ce-mail.phy.syr.edu \
    --domainname phy.syr.edu \
    -v `pwd`/shibboleth:/mnt \
    cosmicexplorer/apache-shibd-mail:latest

```

### Start Apache Containers

The container can then be started with
```sh
export DOMAINNAME=phy.syr.edu
docker-compose up --detach
```
Once the container is running, the metadata can be obtained from the `Shibboleth.sso/Metadata` endpoint. Send the SP metdata to InCommon for federation. 

Preserve the data that this container generates by copying the files `attribute-map.xml`, `inc-md-cert.pem`, `shibboleth2.xml`, `sp-encrypt-cert.pem`, and `sp-encrypt-key.pem` from the `shibboleth/` to `/etc/shibboleth` on the host by running the commands
```sh
mkdir -p /etc/shibboleth
cp shibboleth/* /etc/shibboleth
```

### Stop Apache Container

Finally, shut down the Apache container with
```sh
docker-compose down
```
