export DCC_INSTANCE=seaview.phy.syr.edu
export DCC_DOMAIN=phy.syr.edu

#docker swarm leave --force || true

#FQDN=$(hostname -f)
#IP_ADDR=$(dig +short ${FQDN})
#docker swarm init --advertise-addr ${IP_ADDR}

docker image inspect sugwg/dcc-base &>/dev/null
RET=${?}
set -e

if [ ${RET} -eq 0 ] ; then
  echo "Using existing dcc-base docker image"
else
  echo "Importing dcc-base docker image"
  virt-tar-out -a dcc-syr-disk0.qcow2 / - | docker import - sugwg/dcc-base:latest
fi

export CERT_DIR=$(mktemp -d)
sudo chmod 700 ${CERT_DIR}
sed -e 's///g' /etc/grid-security/igtf-ca-bundle.crt > ${CERT_DIR}/igtf-ca-bundle.crt
sudo cp -a /etc/grid-security/hostkey.pem ${CERT_DIR}
sudo cp -a /etc/grid-security/hostcert.pem ${CERT_DIR}
sudo cp -a /etc/shibboleth/sp-encrypt-cert.pem ${CERT_DIR}
sudo cp -a /etc/shibboleth/sp-encrypt-key.pem ${CERT_DIR}
sudo chown ${USER} ${CERT_DIR}/*.pem
#docker secret create https_chain_file ${CERT_DIR}/igtf-ca-bundle.crt
#docker secret create https_cert_file ${CERT_DIR}/hostcert.pem
#docker secret create https_privkey_file ${CERT_DIR}/hostkey.pem
#docker secret create shibboleth_sp_encrypt_cert ${CERT_DIR}/sp-encrypt-cert.pem
#docker secret create shibboleth_sp_encrypt_privkey ${CERT_DIR}/sp-encrypt-key.pem
#sudo rm -rf ${CERT_DIR}

sudo rm -rf  /srv/docker/dcc
sudo mkdir -p /srv/docker/dcc/etc/shibboleth

sudo cp /etc/shibboleth/shibboleth2.xml /srv/docker/dcc/etc/shibboleth/
sudo cp /etc/shibboleth/attribute-map.xml /srv/docker/dcc/etc/shibboleth/
/usr/bin/curl -O -s https://ds.incommon.org/certs/inc-md-cert.pem
/bin/chmod 644 inc-md-cert.pem
sudo cp inc-md-cert.pem /srv/docker/dcc/etc/shibboleth/inc-md-cert.pem
rm -f inc-md-cert.pem
sudo /bin/chmod 644 /srv/docker/dcc/etc/shibboleth/*

docker build --build-arg=DCC_INSTANCE=${DCC_INSTANCE} -t sugwg/dcc:latest .

if [ $(uname) == "Darwin" ] ; then
  sudo chown -R ${USER} /srv/docker/dcc
fi

set +e
