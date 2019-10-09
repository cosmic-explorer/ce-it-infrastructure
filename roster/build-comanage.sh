#!/bin/bash -v

set -e

pushd comanage-registry-docker

export COMANAGE_REGISTRY_VERSION=3.2.2
export COMANAGE_REGISTRY_BASE_IMAGE_VERSION=1

pushd comanage-registry-base
TAG="${COMANAGE_REGISTRY_VERSION}-${COMANAGE_REGISTRY_BASE_IMAGE_VERSION}"
docker build \
  --build-arg COMANAGE_REGISTRY_VERSION=${COMANAGE_REGISTRY_VERSION} \
  -t comanage-registry-base:${TAG} .
popd

export COMANAGE_REGISTRY_SHIBBOLETH_SP_BASE_IMAGE_VERSION=1

pushd comanage-registry-shibboleth-sp-base
TAG="${COMANAGE_REGISTRY_SHIBBOLETH_SP_BASE_IMAGE_VERSION}"
docker build \
    -t comanage-registry-shibboleth-sp-base:$TAG . 
popd

export COMANAGE_REGISTRY_SHIBBOLETH_SP_IMAGE_VERSION=1
export COMANAGE_REGISTRY_SHIBBOLETH_SP_VERSION=3.2.1

pushd comanage-registry-shibboleth-sp
TAG="${COMANAGE_REGISTRY_VERSION}-shibboleth-sp-${COMANAGE_REGISTRY_SHIBBOLETH_SP_IMAGE_VERSION}"
docker build \
    --build-arg COMANAGE_REGISTRY_VERSION=${COMANAGE_REGISTRY_VERSION} \
    --build-arg COMANAGE_REGISTRY_BASE_IMAGE_VERSION=${COMANAGE_REGISTRY_BASE_IMAGE_VERSION} \
    --build-arg COMANAGE_REGISTRY_SHIBBOLETH_SP_BASE_IMAGE_VERSION=${COMANAGE_REGISTRY_SHIBBOLETH_SP_BASE_IMAGE_VERSION} \
    --build-arg COMANAGE_REGISTRY_SHIBBOLETH_SP_VERSION=${COMANAGE_REGISTRY_SHIBBOLETH_SP_VERSION} \
    -t comanage-registry:$TAG .
popd

docker swarm init --advertise-addr $(hostname --ip-address)

echo "badgers" | docker secret create mariadb_root_password - 
echo "badgers" | docker secret create mariadb_password - 
echo "badgers" | docker secret create comanage_registry_database_user_password - 

cp /etc/grid-security/igtf-ca-bundle.crt /etc/grid-security/hostcert.pem .
cat igtf-ca-bundle.crt hostcert.pem > fullchain.cert.pem
CERT_DIR=$(mktemp -d)
sudo cp -a /etc/shibboleth/sp-encrypt-cert.pem ${CERT_DIR}
sudo cp -a /etc/grid-security/hostkey.pem ${CERT_DIR}
sudo cp -a /etc/shibboleth/sp-encrypt-key.pem ${CERT_DIR}
sudo chown ${USER} ${CERT_DIR}/*.pem
mv ${CERT_DIR}/*.pem .
sudo rmdir ${CERT_DIR}

docker secret create https_cert_file fullchain.cert.pem
docker secret create https_privkey_file hostkey.pem
docker secret create shibboleth_sp_encrypt_cert sp-encrypt-cert.pem
docker secret create shibboleth_sp_encrypt_privkey sp-encrypt-key.pem

sudo mkdir -p /srv/docker/var/lib/mysql
sudo mkdir -p /srv/docker/srv/comanage-registry/local
sudo mkdir -p /srv/docker/etc/shibboleth

sudo cp /etc/shibboleth/shibboleth2.xml /srv/docker/etc/shibboleth/
sudo cp /etc/shibboleth/attribute-map.xml /srv/docker/etc/shibboleth/

export COMANAGE_REGISTRY_ADMIN_GIVEN_NAME=Duncan
export COMANAGE_REGISTRY_ADMIN_FAMILY_NAME=Brown
export COMANAGE_REGISTRY_ADMIN_USERNAME=dabrown@syr.edu

export COMANAGE_REGISTRY_VIRTUAL_HOST_FQDN=sugwg-test1.phy.syr.edu

export COMANAGE_REGISTRY_SLAPD_BASE_IMAGE_VERSION=1

pushd comanage-registry-slapd-base
TAG="${COMANAGE_REGISTRY_SLAPD_BASE_IMAGE_VERSION}"
docker build \
  -t comanage-registry-slapd-base:${TAG} .
popd

export COMANAGE_REGISTRY_SLAPD_IMAGE_VERSION=1

pushd comanage-registry-slapd
TAG="${COMANAGE_REGISTRY_SLAPD_IMAGE_VERSION}"
docker build \
    --build-arg COMANAGE_REGISTRY_SLAPD_BASE_IMAGE_VERSION=${COMANAGE_REGISTRY_SLAPD_BASE_IMAGE_VERSION} \
    -t comanage-registry-slapd:$TAG . 
popd

docker secret create slapd_chain_file igtf-ca-bundle.crt
docker secret create slapd_cert_file hostcert.pem
docker secret create slapd_privkey_file hostkey.pem

echo "{SSHA}bnjbUkuyt0MKJnDXbtwE2VjtoTeKjqFw" | docker secret create olc_root_pw

sudo mkdir -p /srv/docker/var/lib/ldap
sudo mkdir -p /srv/docker/etc/slapd.d

export OLC_SUFFIX=dc=cosmicexplorer,dc=org
export OLC_ROOT_DN=cn=admin,dc=cosmicexplorer,dc=org

popd
