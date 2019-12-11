export STORAGE_PATH=/srv/docker/dcc
export APACHE_SHIBD_DIR=/root/ce-dcc/apache-shibd
export DCC_INSTANCE=dcc.cosmicexplorer.org
export DCC_HOSTNAME=dcc.cosmicexplorer.org
export DCC_DOMAINNAME=cosmicexplorer.org
export MYSQL_ROOT_PASSWD=badgers
export MYSQL_DOCDBRW_PASSWD=mushroommushroom
export MYSQL_DOCDBRO_PASSWD=badgersbadgersbadgers
export HYDRA_PASSWD=aghitsasnake
export SECRETS_SYSTEM=itsabadgersbadgersbadgers
export DCC_REST_SECRET=oooosnake
export REST_AUTHORIZED_EPPN=dabrown@syr.edu
export SHIB_HEADER_SECRET=mushroom

# temporary secret files until we can use swarm
echo "${MYSQL_ROOT_PASSWD}" > ./mysql_root_passwd.txt
echo "${MYSQL_ROOT_PASSWD}" > ./mariadb_root_password.txt
echo "${MYSQL_DOCDBRW_PASSWD}" > ./mysql_docdbrw_passwd.txt
echo "${MYSQL_DOCDBRO_PASSWD}" > ./mysql_docdbro_passwd.txt
echo "${REST_AUTHORIZED_EPPN}" > ./rest_authorized_eppn.txt
echo "${SHIB_HEADER_SECRET}" > ./shib_header_secret.txt
