. ../roster/comanage-env.sh
. mailman-env.sh

if [ -d ${STORAGE_PATH} ] ; then
  echo "${STORAGE_PATH} already exists"
  echo "Do you want to remove this directory or keep it? Type remove or keep"
  read RESPONSE
  if test x$RESPONSE == xremove ; then
    echo "Are you sure you want to remove ${STORAGE_PATH}?"
    echo "Type remove to delete ${STORAGE_PATH} or anything else to exit"
    read REMOVE
    if test x$REMOVE == xremove ; then
      echo "Removing COmange storage"
      sudo rm -rf rm -rf ${STORAGE_PATH}/etc/ ${STORAGE_PATH}/srv/ ${STORAGE_PATH}/var/
      echo "${STORAGE_PATH}/letsencrypt has not been removed. This must be removed manually, if desired."
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

# FIXME
# docker swarm leave --force || true

pushd comanage-registry-docker

pushd comanage-registry-mailman/core
docker build -t cosmicexplorer/mailman-core:0.2.1 .
popd

pushd comanage-registry-mailman/web
docker build -t cosmicexplorer/mailman-web:0.2.1 .
popd

pushd comanage-registry-mailman/apache-shib
docker build \
  --build-arg COMANAGE_REGISTRY_VERSION=${COMANAGE_REGISTRY_VERSION} \
    --build-arg COMANAGE_REGISTRY_BASE_IMAGE_VERSION=${COMANAGE_REGISTRY_BASE_IMAGE_VERSION} \
    -t cosmicexplorer/mailman-core-apache-shib:1 .
popd

pushd comanage-registry-mailman/postfix
docker build -t cosmicexplorer/mailman-postfix:2 .
popd

# FIXME
# docker swarm init --advertise-addr 127.0.0.1

#echo "${HYPERKITTY_API_KEY}" | docker secret create hyperkitty_api_key -
#echo "${POSTGRESS_PASSWORD}" | docker secret create postgres_password -
#echo "postgres://mailman:${POSTGRESS_PASSWORD}@database/mailmandb" | docker secret create mailman_database_url -
#echo "${MAILMAN_REST_PASSWORD}" | docker secret create mailman_rest_password -
#echo "${MAILMAN_WEB_SECRET_KEY}" | docker secret create mailman_web_secret_key -

CERT_DIR=$(mktemp -d)
sudo cp -a ${APACHE_SHIBD_DIR}/shibboleth/sp-encrypt-cert.pem ${CERT_DIR}
sudo cp -a ${APACHE_SHIBD_DIR}/shibboleth/sp-encrypt-key.pem ${CERT_DIR}
sudo chown ${USER} ${CERT_DIR}/*.pem
mv ${CERT_DIR}/*.pem .
sudo rmdir ${CERT_DIR}

# FIXME
# docker secret create shibboleth_sp_encrypt_cert sp-encrypt-cert.pem
# docker secret create shibboleth_sp_encrypt_privkey sp-encrypt-key.pem

# FIXME
# temporary secret files until we have macvlan
cat sp-encrypt-cert.pem > ../shibboleth_sp_encrypt_cert.txt
cat sp-encrypt-key.pem > ../shibboleth_sp_encrypt_privkey.txt
rm -f sp-encrypt-cert.pem sp-encrypt-key.pem

sudo mkdir -p ${STORAGE_PATH}/core
sudo mkdir -p ${STORAGE_PATH}/core/var/data
sudo touch ${STORAGE_PATH}/settings.py
sudo mkdir -p ${STORAGE_PATH}/web
sudo mkdir -p ${STORAGE_PATH}/database
sudo mkdir -p ${STORAGE_PATH}/etc/shibboleth
sudo mkdir -p ${STORAGE_PATH}/letsencrypt/config

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

popd

trap - ERR
