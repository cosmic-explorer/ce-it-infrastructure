export STORAGE_PATH=/srv/docker/mailman
export APACHE_SHIBD_DIR=/root/ce-mail/apache-shibd

export HYPERKITTY_API_KEY="badgers"
export POSTGRESS_PASSWORD="badgers"
export MAILMAN_REST_PASSWORD="badgers"
export MAILMAN_WEB_SECRET_KEY="badgers"

export SERVE_FROM_DOMAIN=mail.cosmicexplorer.org
export MAILMAN_ADMIN_USER=dbrown
export MAILMAN_ADMIN_EMAIL=dabrown@syr.edu

export POSTFIX_MAILNAME=mail.cosmicexplorer.org
export POSTFIX_MYHOSTNAME=mail.cosmicexplorer.org
export POSTFIX_MYNETWORKS="192.168.102.0/24"
export POSTFIX_RELAYHOST="smtp-host.syr.edu"

export SECRET_KEY="badgers"

# FIXME: need to check these
#export DJANGO_ALLOWED_HOSTS=""
#export MAILMAN_HOST_IP=""
#export SMTP_HOST="smtp-host.syr.edu"

# temporary storage of secrets until we have macvlan
echo "${HYPERKITTY_API_KEY}" > ./hyperkitty_api_key.txt
echo "${POSTGRESS_PASSWORD}" > ./postgres_password.txt
echo "postgres://mailman:${POSTGRESS_PASSWORD}@database/mailmandb" > ./mailman_database_url.txt
echo "${MAILMAN_REST_PASSWORD}" > ./mailman_rest_password.txt
echo "${MAILMAN_WEB_SECRET_KEY}" > ./mailman_web_secret_key.txt

# temporary use of compose until we have macvlan
export COMPOSE_IGNORE_ORPHANS=1
