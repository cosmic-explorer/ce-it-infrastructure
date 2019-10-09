set -e

docker swarm leave --force || true
sudo rm -rf /srv/docker/comanage

pushd comanage-registry-docker

pushd comanage-registry-mailman/core
docker build -t cosmicexplorer/mailman-core:0.2.1 .
popd

pushd comanage-registry-mailman/web
docker build -t cosmicexplorer/mailman-web:0.2.1 .
popd

pushd comanage-registry-mailman/apache-shib
docker build -t cosmicexplorer/mailman-core-apache-shib .
popd

pushd comanage-registry-mailman/postfix
docker build -t cosmicexplorer/mailman-postfix .
popd

mkdir -p /srv/docker/mailman/core
mkdir -p /srv/docker/mailman/web
mkdir -p /srv/docker/mailman/database
mkdir -p /srv/docker/mailman/shib

sed -e 's/^M//g' /etc/grid-security/igtf-ca-bundle.crt > igtf-ca-bundle.crt
cp /etc/grid-security/hostcert.pem .
cp hostcert.pem fullchain.cert.pem
echo >> fullchain.cert.pem
cat igtf-ca-bundle.crt >> fullchain.cert.pem
CERT_DIR=$(mktemp -d)
sudo cp -a /etc/shibboleth/sp-encrypt-cert.pem ${CERT_DIR}
sudo cp -a /etc/grid-security/hostkey.pem ${CERT_DIR}
sudo cp -a /etc/shibboleth/sp-encrypt-key.pem ${CERT_DIR}
sudo chown ${USER} ${CERT_DIR}/*.pem
mv ${CERT_DIR}/*.pem .
sudo rmdir ${CERT_DIR}

docker swarm init --advertise-addr $(hostname --ip-address)

docker secret create https_cert_file fullchain.cert.pem
docker secret create https_privkey_file hostkey.pem

echo "postgres://mailman:badgers@database/mailmandb" | docker secret create mailman_database_url -
echo "badgers" | docker secret create hyperkitty_api_key -
echo "badgers" | docker secret create mailman_rest_password -
echo "badgers" | docker secret create mailman_web_secret_key -
echo "badgers" | docker secret create postgres_password -
