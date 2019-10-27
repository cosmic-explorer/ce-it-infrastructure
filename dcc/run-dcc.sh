trap 'kill -INT $$' ERR

export STORAGE_PATH=/srv/docker/dcc

if [ ! -d ${STORAGE_PATH} ] ; then
  echo "Error: ${STORAGE_PATH} must have been created to run this script"
  kill -INT $$
fi

export DCC_INSTANCE=seaview.phy.syr.edu
export DCC_HOSTNAME=seaview.phy.syr.edu
export DCC_DOMAINNAME=phy.syr.edu
export MYSQL_ROOT_PASSWD=badgers
export MYSQL_DOCDBRW_PASSWD=herecomethebadgers
export MYSQL_DOCDBRO_PASSWD=badgersbadgersbadgers

docker swarm leave --force &>/dev/null || true
docker swarm init --advertise-addr 127.0.0.1

export CERT_DIR=$(mktemp -d)
sudo chmod 700 ${CERT_DIR}
sed -e 's///g' /etc/grid-security/igtf-ca-bundle.crt > ${CERT_DIR}/igtf-ca-bundle.crt
sudo cp -a /etc/grid-security/hostkey.pem ${CERT_DIR}
sudo cp -a /etc/grid-security/hostcert.pem ${CERT_DIR}
sudo cp -a /etc/shibboleth/sp-encrypt-cert.pem ${CERT_DIR}
sudo cp -a /etc/shibboleth/sp-encrypt-key.pem ${CERT_DIR}
sudo chown ${USER} ${CERT_DIR}/*.pem
docker secret create https_chain_file ${CERT_DIR}/igtf-ca-bundle.crt
docker secret create https_cert_file ${CERT_DIR}/hostcert.pem
docker secret create https_privkey_file ${CERT_DIR}/hostkey.pem
docker secret create shibboleth_sp_encrypt_cert ${CERT_DIR}/sp-encrypt-cert.pem
docker secret create shibboleth_sp_encrypt_privkey ${CERT_DIR}/sp-encrypt-key.pem
echo ${MYSQL_ROOT_PASSWD} | docker secret create mysql_root_passwd -
echo ${MYSQL_ROOT_PASSWD}  | docker secret create mariadb_root_password -
echo ${MYSQL_DOCDBRW_PASSWD} | docker secret create mysql_docdbrw_passwd -
echo ${MYSQL_DOCDBRO_PASSWD} | docker secret create mysql_docdbro_passwd -

echo ${DCC_REST_SECRET} | docker secret create dcc_rest_secret -

docker stack deploy --compose-file dcc.yml dcc

trap - ERR
