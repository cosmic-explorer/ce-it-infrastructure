export STORAGE_PATH=/srv/docker/dcc
export DCC_INSTANCE=seaview.phy.syr.edu
export DCC_HOSTNAME=seaview.phy.syr.edu
export DCC_DOMAINNAME=phy.syr.edu
export MYSQL_ROOT_PASSWD=badgers
export MYSQL_DOCDBRW_PASSWD=herecomethebadgers
export MYSQL_DOCDBRO_PASSWD=badgersbadgersbadgers
export HYDRA_PASSWD=aghitsasnake

echo "Checking for ${STORAGE_PATH}"

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
else
  echo "${STORAGE_PATH} not found, creating"
fi

docker swarm leave --force &>/dev/null || true

docker image inspect cosmicexplorer/dcc-base:3.3.0 &>/dev/null
RET=${?}

trap 'kill -INT $$' ERR

if [ ${RET} -eq 0 ] ; then
  echo "Using existing dcc-base docker image"
else
  echo "Importing dcc-base docker image"
  virt-tar-out -a dcc-syr-disk0.qcow2 / - | docker import - sugwg/dcc-base:3.3.0
fi

export CERT_DIR=$(mktemp -d)
sudo chmod 700 ${CERT_DIR}
sed -e 's///g' /etc/grid-security/igtf-ca-bundle.crt > ${CERT_DIR}/igtf-ca-bundle.crt
sudo cp -a /etc/grid-security/hostkey.pem ${CERT_DIR}
sudo cp -a /etc/grid-security/hostcert.pem ${CERT_DIR}
sudo cp -a /etc/shibboleth/sp-encrypt-cert.pem ${CERT_DIR}
sudo cp -a /etc/shibboleth/sp-encrypt-key.pem ${CERT_DIR}
sudo chown ${USER} ${CERT_DIR}/*.pem
echo ${MYSQL_ROOT_PASSWD} > ${CERT_DIR}/mysql_root_passwd.txt
echo ${MYSQL_DOCDBRW_PASSWD} > ${CERT_DIR}/mysql_docdbrw_passwd.txt
echo ${MYSQL_DOCDBRO_PASSWD} > ${CERT_DIR}/mysql_docdbro_passwd.txt

sudo mkdir -p ${STORAGE_PATH}/etc/shibboleth

sudo cp /etc/shibboleth/shibboleth2.xml ${STORAGE_PATH}/etc/shibboleth/
sudo cp /etc/shibboleth/attribute-map.xml ${STORAGE_PATH}/etc/shibboleth/
/usr/bin/curl -O -s https://ds.incommon.org/certs/inc-md-cert.pem
/bin/chmod 644 inc-md-cert.pem
sudo cp inc-md-cert.pem ${STORAGE_PATH}/etc/shibboleth/inc-md-cert.pem
rm -f inc-md-cert.pem
sudo /bin/chmod 644 ${STORAGE_PATH}/etc/shibboleth/*

docker build --build-arg=DCC_INSTANCE=${DCC_INSTANCE} --rm -t cosmicexplorer/dcc:3.3.0 .
docker build -f Dockerfile.bootstrap --rm -t cosmicexplorer/dcc-bootstrap:3.3.0 .

sudo mkdir -p ${STORAGE_PATH}/usr1/www/html/DocDB
sudo mkdir -p ${STORAGE_PATH}/usr1/www/html/public
sudo mkdir -p ${STORAGE_PATH}/var/lib/mysql
sudo mkdir -p ${STORAGE_PATH}/usr2/GLIMPSE
sudo mkdir -p ${STORAGE_PATH}/var/lib/postgresql/data

if [ $(uname) == "Darwin" ] ; then
  sudo chown -R ${USER} ${STORAGE_PATH}
fi

docker network rm dcc-bootstrap-network &>/dev/null || true
docker network create dcc-bootstrap-network

docker run --rm --network dcc-bootstrap-network \
  --name hydra-database \
  -v ${STORAGE_PATH}/var/lib/postgresql/data:/var/lib/postgresql/data \
  -e POSTGRES_USER=hydra \
  -e POSTGRES_PASSWORD=${HYDRA_PASSWD} \
  -e POSTGRES_DB=hydra \
  -d postgres:9.6

docker run -it --rm \
  --network dcc-bootstrap-network \
  cosmicexplorer/wait-port:0.2.6 \
  wait-port hydra-database:5432

export SECRETS_SYSTEM=$(export LC_CTYPE=C; cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
export DSN="postgres://hydra:${HYDRA_PASSWD}@hydra-database:5432/hydra?sslmode=disable"

docker run -it --rm \
  --network dcc-bootstrap-network \
  oryd/hydra:v1.0.8 \
  migrate sql --yes $DSN

docker run -d --rm \
  --network dcc-bootstrap-network \
  --name hydra-bootstrap-server \
  -e SECRETS_SYSTEM=${SECRETS_SYSTEM} \
  -e DSN=$DSN \
  -e URLS_SELF_ISSUER=http://127.0.0.1:9000/ \
  -e URLS_CONSENT=http://127.0.0.1:9020/consent \
  -e URLS_LOGIN=http://127.0.0.1:9020/login \
  oryd/hydra:v1.0.8 serve all --dangerous-force-http

docker run -it --rm \
  --network dcc-bootstrap-network \
  cosmicexplorer/wait-port:0.2.6 \
  wait-port hydra-bootstrap-server:4445

docker run -it --rm \
  --network dcc-bootstrap-network \
  cosmicexplorer/wait-port:0.2.6 \
  wait-port hydra-bootstrap-server:4444

export DCC_REST_SECRET=$(export LC_CTYPE=C; cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
docker run --rm -it \
  --network dcc-bootstrap-network \
  oryd/hydra:v1.0.8 \
  clients create \
    --endpoint http://hydra-bootstrap-server:4445 \
    --id dcc-rest-api \
    --secret ${DCC_REST_SECRET} \
    --grant-types client_credentials \
    --response-types token,code

docker stop hydra-bootstrap-server
docker stop hydra-database
docker network rm dcc-bootstrap-network

echo "OAuth2 server SECRETS_SYSTEM=${SECRETS_SYSTEM}"
echo "OAuth2 server DCC_REST_SECRET=${DCC_REST_SECRET}"

trap - ERR
