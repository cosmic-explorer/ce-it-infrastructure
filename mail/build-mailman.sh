STORAGE_PATH=/srv/docker/mailman

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

docker secret rm hyperkitty_api_key mailman_rest_password mailman_web_secret_key postgres_password mailman_database_url || true

pushd comanage-registry-docker

pushd comanage-registry-mailman/core
docker build -t cosmicexplorer/mailman-core:0.2.1 .
popd

pushd comanage-registry-mailman/web
docker build -t cosmicexplorer/mailman-web:0.2.1 .
popd

pushd comanage-registry-mailman/apache-shib
docker build \
--build-arg COMANAGE_REGISTRY_VERSION=3.2.2 \
--build-arg COMANAGE_REGISTRY_BASE_IMAGE_VERSION=1 \
-t cosmicexplorer/mailman-core-apache-shib .
popd

pushd comanage-registry-mailman/postfix
docker build -t cosmicexplorer/mailman-postfix .
popd

sudo mkdir -p ${STORAGE_PATH}/core
sudo mkdir -p ${STORAGE_PATH}/web
sudo mkdir -p ${STORAGE_PATH}/database

echo "postgres://mailman:badgers@database/mailmandb" | docker secret create mailman_database_url -
echo "badgers" | docker secret create hyperkitty_api_key -
echo "badgers" | docker secret create mailman_rest_password -
echo "badgers" | docker secret create mailman_web_secret_key -
echo "badgers" | docker secret create postgres_password -

sudo mkdir -p ${STORAGE_PATH}/etc/shibboleth

sudo cp /etc/shibboleth/shibboleth2.xml ${STORAGE_PATH}/etc/shibboleth/
sudo cp /etc/shibboleth/attribute-map.xml ${STORAGE_PATH}/etc/shibboleth/
/usr/bin/curl -O -s https://ds.incommon.org/certs/inc-md-cert.pem
chmod 644 inc-md-cert.pem
sudo cp inc-md-cert.pem ${STORAGE_PATH}/etc/shibboleth/inc-md-cert.pem
rm -f inc-md-cert.pem
sudo chmod -R 644 ${STORAGE_PATH}/etc/shibboleth

if [ $(uname) == "Darwin" ] ; then
  sudo chown -R ${USER} ${STORAGE_PATH}
fi

popd

trap - ERR
