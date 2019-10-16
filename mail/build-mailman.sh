set -e

sudo rm -rf /srv/docker/mailman
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

sudo mkdir -p /srv/docker/mailman/core
sudo mkdir -p /srv/docker/mailman/web
sudo mkdir -p /srv/docker/mailman/database
sudo mkdir -p /srv/docker/mailman/shib

echo "postgres://mailman:badgers@database/mailmandb" | docker secret create mailman_database_url -
echo "badgers" | docker secret create hyperkitty_api_key -
echo "badgers" | docker secret create mailman_rest_password -
echo "badgers" | docker secret create mailman_web_secret_key -
echo "badgers" | docker secret create postgres_password -

sudo mkdir -p /srv/docker/mailman/etc/shibboleth

sudo cp /etc/shibboleth/shibboleth2.xml /srv/docker/mailman/etc/shibboleth/
sudo cp /etc/shibboleth/attribute-map.xml /srv/docker/mailman/etc/shibboleth/
/usr/bin/curl -O -s https://ds.incommon.org/certs/inc-md-cert.pem
chmod 644 inc-md-cert.pem
sudo cp inc-md-cert.pem /srv/docker/mailman/etc/shibboleth/inc-md-cert.pem
rm -f inc-md-cert.pem
sudo chmod 644 -R -v /srv/docker/mailman/etc/shibboleth

if [ $(uname) == "Darwin" ] ; then
  sudo chown -R ${USER} /srv/docker/mailman
fi

popd
set +e
