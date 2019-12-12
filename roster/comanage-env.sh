export STORAGE_PATH=/srv/docker/comanage
export APACHE_SHIBD_DIR=/root/ce-roster/apache-shibd
export COMANAGE_REGISTRY_VERSION=3.2.3
export COMANAGE_REGISTRY_BASE_IMAGE_VERSION=1
export COMANAGE_REGISTRY_SHIBBOLETH_SP_BASE_IMAGE_VERSION=1
export COMANAGE_REGISTRY_SHIBBOLETH_SP_IMAGE_VERSION=1
export COMANAGE_REGISTRY_SHIBBOLETH_SP_VERSION=3.2.1
export COMANAGE_REGISTRY_ADMIN_GIVEN_NAME=Duncan
export COMANAGE_REGISTRY_ADMIN_FAMILY_NAME=Brown
export COMANAGE_REGISTRY_ADMIN_USERNAME=dabrown@syr.edu
export COMANAGE_REGISTRY_VIRTUAL_HOST_FQDN=roster.cosmicexplorer.org
export COMANAGE_REGISTRY_SLAPD_BASE_IMAGE_VERSION=1
export COMANAGE_REGISTRY_SLAPD_IMAGE_VERSION=1
export OLC_SUFFIX=dc=cosmicexplorer,dc=org
export OLC_ROOT_DN=cn=admin,dc=cosmicexplorer,dc=org
export COMANAGE_REGISTRY_ENABLE_PLUGIN=MailmanProvisioner,ChangelogProvisioner,GithubProvisioner,RestDccProvisioner
export MARIADB_ROOT_PASSWD=badgers
export MARIADB_PASSWD=badgers
export REGISTRY_DATABASE_PASSWD=${MARIADB_PASSWD}
export OLC_ROOT_PASSWD=badgers

# temporary storage of secrets until we have macvlan
echo "${REGISTRY_DATABASE_PASSWD}" > ./comanage_registry_database_user_password.txt
echo "${MARIADB_ROOT_PASSWD}" > ./mariadb_root_password.txt
echo "${MARIADB_PASSWD}" > ./mariadb_password.txt
slappasswd -s ${OLC_ROOT_PASSWD} > ./olc_root_pw.txt

# temporary use of compose until we have macvlan
export COMPOSE_IGNORE_ORPHANS=1
