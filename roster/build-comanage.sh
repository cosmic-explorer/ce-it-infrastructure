. comanage-env.sh

if [ -d ${STORAGE_PATH} ] ; then
  echo "${STORAGE_PATH} already exists"
  echo "Do you want to remove this directory or keep it? Type remove or keep"
  read RESPONSE
  if test x$RESPONSE == xremove ; then
    echo "Are you sure you want to remove ${STORAGE_PATH}?"
    echo "Type remove to delete ${STORAGE_PATH} or anything else to exit"
    read REMOVE
    if test x$REMOVE == xremove ; then
      sudo rm -rf ${STORAGE_PATH}
      sudo mkdir -p ${STORAGE_PATH}
    else
      echo "You did not type remove. Exiting"
      kill -INT $$
    fi
  elif test x$RESPONSE == xkeep ; then
    echo "Using files from ${STORAGE_PATH}"
  else
    echo "Error: unknown response $RESPONSE"
    kill -INT $$
  fi
fi

trap 'trap - ERR; kill -INT $$' ERR

docker swarm leave --force || true

pushd comanage-registry-docker

pushd comanage-registry-base
TAG="${COMANAGE_REGISTRY_VERSION}-${COMANAGE_REGISTRY_BASE_IMAGE_VERSION}"
docker build \
  --build-arg COMANAGE_REGISTRY_VERSION=${COMANAGE_REGISTRY_VERSION} \
  -t comanage-registry-base:${TAG} .
popd

pushd comanage-registry-shibboleth-sp-base
TAG=${COMANAGE_REGISTRY_SHIBBOLETH_SP_VERSION}-${COMANAGE_REGISTRY_SHIBBOLETH_SP_BASE_IMAGE_VERSION}
docker build \
    -t comanage-registry-shibboleth-sp-base:$TAG . 
popd

pushd comanage-registry-shibboleth-sp
TAG="${COMANAGE_REGISTRY_VERSION}-shibboleth-sp-${COMANAGE_REGISTRY_SHIBBOLETH_SP_IMAGE_VERSION}"
docker build \
    --build-arg COMANAGE_REGISTRY_VERSION=${COMANAGE_REGISTRY_VERSION} \
    --build-arg COMANAGE_REGISTRY_BASE_IMAGE_VERSION=${COMANAGE_REGISTRY_BASE_IMAGE_VERSION} \
    --build-arg COMANAGE_REGISTRY_SHIBBOLETH_SP_BASE_IMAGE_VERSION=${COMANAGE_REGISTRY_SHIBBOLETH_SP_BASE_IMAGE_VERSION} \
    --build-arg COMANAGE_REGISTRY_SHIBBOLETH_SP_VERSION=${COMANAGE_REGISTRY_SHIBBOLETH_SP_VERSION} \
    -t comanage-registry:$TAG .
popd

docker swarm init --advertise-addr 127.0.0.1

echo ${MARIADB_ROOT_PASSWD} | docker secret create mariadb_root_password - 
echo ${MARIADB_PASSWD} | docker secret create mariadb_password - 
echo ${REGISTRY_DATABASE_PASSWD} | docker secret create comanage_registry_database_user_password - 

CERT_DIR=$(mktemp -d)
sudo cp -a ${APACHE_SHIBD_DIR}/shibboleth/sp-encrypt-cert.pem ${CERT_DIR}
sudo cp -a ${APACHE_SHIBD_DIR}/shibboleth/sp-encrypt-key.pem ${CERT_DIR}
sudo chown ${USER} ${CERT_DIR}/*.pem
mv ${CERT_DIR}/*.pem .
sudo rmdir ${CERT_DIR}

docker secret create shibboleth_sp_encrypt_cert sp-encrypt-cert.pem
docker secret create shibboleth_sp_encrypt_privkey sp-encrypt-key.pem

# temporary secret files until we have macvlan
cat sp-encrypt-cert.pem > ../shibboleth_sp_encrypt_cert.txt
cat sp-encrypt-key.pem > ../shibboleth_sp_encrypt_privkey.txt

rm -f sp-encrypt-cert.pem sp-encrypt-key.pem

sudo mkdir -p ${STORAGE_PATH}/var/lib/mysql
sudo mkdir -p ${STORAGE_PATH}/srv/comanage-registry/local
sudo mkdir -p ${STORAGE_PATH}/etc/shibboleth
sudo mkdir -p ${STORAGE_PATH}/letsencrypt/config

pushd comanage-registry-slapd-base
TAG="${COMANAGE_REGISTRY_SLAPD_BASE_IMAGE_VERSION}"
docker build \
  -t comanage-registry-slapd-base:${TAG} .
popd

pushd comanage-registry-slapd
TAG="${COMANAGE_REGISTRY_SLAPD_IMAGE_VERSION}"
docker build \
    --build-arg COMANAGE_REGISTRY_SLAPD_BASE_IMAGE_VERSION=${COMANAGE_REGISTRY_SLAPD_BASE_IMAGE_VERSION} \
    -t comanage-registry-slapd:$TAG . 
popd

echo "{SSHA}bnjbUkuyt0MKJnDXbtwE2VjtoTeKjqFw" | docker secret create olc_root_pw -

sudo mkdir -p ${STORAGE_PATH}/var/lib/ldap
sudo mkdir -p ${STORAGE_PATH}/etc/slapd.d

popd

sudo cp ${APACHE_SHIBD_DIR}/shibboleth/shibboleth2.xml ${STORAGE_PATH}/etc/shibboleth/
sudo cp attribute-map.xml ${STORAGE_PATH}/etc/shibboleth/
/usr/bin/curl -O -s https://ds.incommon.org/certs/inc-md-cert.pem
/bin/chmod 644 inc-md-cert.pem
sudo cp inc-md-cert.pem ${STORAGE_PATH}/etc/shibboleth/inc-md-cert.pem
rm -f inc-md-cert.pem
sudo /bin/chmod 644 ${STORAGE_PATH}/etc/shibboleth/*

if [ $(uname) == "Darwin" ] ; then
  sudo chown -R ${USER} ${STORAGE_PATH}
fi

trap - ERR
