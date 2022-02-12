export STORAGE_PATH=/srv/docker/mailman
export APACHE_SHIBD_DIR=/root/ce-mail/apache-shibd

export HYPERKITTY_API_KEY="badgers"
export POSTGRESS_PASSWORD="badgers"
export MAILMAN_REST_PASSWORD="badgers"
export MAILMAN_WEB_SECRET_KEY="badgers"

export MAILMAN_VIRTUAL_HOST_FQDN=mail.cosmicexplorer.org
export SERVE_FROM_DOMAIN=${MAILMAN_VIRTUAL_HOST_FQDN}
export MAILMAN_ADMIN_USER=mailman_admin
export MAILMAN_ADMIN_EMAIL=dabrown@syr.edu

export POSTFIX_MAILNAME=${MAILMAN_VIRTUAL_HOST_FQDN}
export POSTFIX_MYHOSTNAME=${MAILMAN_VIRTUAL_HOST_FQDN}
export POSTFIX_MYNETWORKS="172.30.100.0/24"
export POSTFIX_RELAYHOST="smtp-relay.syr.edu"

export DKIM_SIGNING_DOMAIN=cosmicexplorer.org
export DKIM_SELECTOR=mailman022022
export MAILMAN_PRIVATE_IP=172.30.100.6
export MAILMAN_PRIVATE_FQDN=mail_mailman-core_1.roster_roster-net

# temporary storage of secrets until we have macvlan
echo "${HYPERKITTY_API_KEY}" > ./hyperkitty_api_key.txt
echo "${POSTGRESS_PASSWORD}" > ./postgres_password.txt
echo "postgres://mailman:${POSTGRESS_PASSWORD}@database/mailmandb" > ./mailman_database_url.txt
echo "${MAILMAN_REST_PASSWORD}" > ./mailman_rest_password.txt
echo "${MAILMAN_WEB_SECRET_KEY}" > ./mailman_web_secret_key.txt

# temporary use of compose until we have macvlan
export COMPOSE_IGNORE_ORPHANS=1
