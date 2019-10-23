export STORAGE_PATH=/srv/docker/dcc

export DCC_INSTANCE=seaview.phy.syr.edu
export DCC_HOSTNAME=seaview.phy.syr.edu
export DCC_DOMAINNAME=phy.syr.edu
export MYSQL_ROOT_PASSWD=badgers
export MYSQL_DOCDBRW_PASSWD=herecomethebadgers
export MYSQL_DOCDBRO_PASSWD=badgersbadgersbadgers

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
#echo ${MYSQL_ROOT_PASSWD} | docker secret create mysql_root_passwd -
#echo ${MYSQL_DOCDBRW_PASSWD} | docker secret create mysql_docdbrw_passwd -
#echo ${MYSQL_DOCDBRO_PASSWD} | docker secret create mysql_docdbro_passwd -
echo ${MYSQL_ROOT_PASSWD} > ${CERT_DIR}/mysql_root_passwd.txt
echo ${MYSQL_DOCDBRW_PASSWD} > ${CERT_DIR}/mysql_docdbrw_passwd.txt
echo ${MYSQL_DOCDBRO_PASSWD} > ${CERT_DIR}/mysql_docdbro_passwd.txt
#sudo rm -rf ${CERT_DIR}

sudo mkdir -p ${STORAGE_PATH}/etc/shibboleth

sudo cp /etc/shibboleth/shibboleth2.xml ${STORAGE_PATH}/etc/shibboleth/
sudo cp /etc/shibboleth/attribute-map.xml ${STORAGE_PATH}/etc/shibboleth/
/usr/bin/curl -O -s https://ds.incommon.org/certs/inc-md-cert.pem
/bin/chmod 644 inc-md-cert.pem
sudo cp inc-md-cert.pem ${STORAGE_PATH}/etc/shibboleth/inc-md-cert.pem
rm -f inc-md-cert.pem
sudo /bin/chmod 644 ${STORAGE_PATH}/etc/shibboleth/*

docker build --build-arg=DCC_INSTANCE=${DCC_INSTANCE} -t sugwg/dcc:latest .

sudo mkdir -p ${STORAGE_PATH}/usr1/www/html/DocDB
sudo mkdir -p ${STORAGE_PATH}/usr1/www/html/public

if [ $(uname) == "Darwin" ] ; then
  sudo chown -R ${USER} ${STORAGE_PATH}
fi

set +e
