trap 'trap - ERR; kill -INT $$' ERR

. dcc-environment.sh

if [ ! -d ${STORAGE_PATH} ] ; then
  echo "Error: ${STORAGE_PATH} must have been created to run this script"
  kill -INT $$
fi

# FIXME
# docker swarm leave --force &>/dev/null || true
# docker swarm init --advertise-addr 127.0.0.1

export CERT_DIR=$(mktemp -d)
sudo chmod 700 ${CERT_DIR}
sudo cp -a ${APACHE_SHIBD_DIR}/shibboleth/sp-encrypt-cert.pem ${CERT_DIR}
sudo cp -a ${APACHE_SHIBD_DIR}/shibboleth/sp-encrypt-key.pem ${CERT_DIR}
sudo chown ${USER} ${CERT_DIR}/*.pem

# FIXME
# docker secret create shibboleth_sp_encrypt_cert ${CERT_DIR}/sp-encrypt-cert.pem
# docker secret create shibboleth_sp_encrypt_privkey ${CERT_DIR}/sp-encrypt-key.pem
# echo ${MYSQL_ROOT_PASSWD} | docker secret create mysql_root_passwd -
# echo ${MYSQL_ROOT_PASSWD}  | docker secret create mariadb_root_password -
# echo ${MYSQL_DOCDBRW_PASSWD} | docker secret create mysql_docdbrw_passwd -
# echo ${MYSQL_DOCDBRO_PASSWD} | docker secret create mysql_docdbro_passwd -
# echo ${SHIB_HEADER_SECRET} | docker secret create shib_header_secret -
# echo ${REST_AUTHORIZED_EPPN} | docker secret create rest_authorized_eppn -
cat ${CERT_DIR}/sp-encrypt-cert.pem > ./shibboleth_sp_encrypt_cert.txt
cat ${CERT_DIR}/sp-encrypt-key.pem > ./shibboleth_sp_encrypt_privkey.txt

rm -rf ${CERT_DIR}

# FIXME
# docker stack deploy --compose-file dcc.yml dcc

trap - ERR
