export STORAGE_PATH=/srv/docker/mailman
export APACHE_SHIBD_DIR=/root/ce-mail/apache-shibd

export SERVE_FROM_DOMAIN=mail.cosmicexplorer.org
export MAILMAN_ADMIN_USER=dbrown
export MAILMAN_ADMIN_EMAIL=dabrown@syr.edu
export POSTFIX_MAILNAME=mail.cosmicexplorer.org
export POSTFIX_MYHOSTNAME=mail.cosmicexplorer.org
export POSTFIX_MYNETWORKS="192.168.102.0/24"

# temporary use of compose until we have macvlan
export COMPOSE_IGNORE_ORPHANS=1

export HYPERKITTY_API_KEY
export MAILMAN_DATABASE_URL
export MAILMAN_REST_PASSWORD
export MAILMAN_WEB_SECRET_KEY

export SECRET_KEY
export SERVE_FROM_DOMAIN
export DJANGO_ALLOWED_HOSTS
export MAILMAN_REST_URL="http://mailman-core:8001"
export MAILMAN_REST_USER
export MAILMAN_REST_PASSWORD
export HYPERKITTY_API_KEY
export MAILMAN_HOST_IP

export SERVE_FROM_DOMAIN
export SMTP_HOST
export SMTP_PORT
export SMTP_HOST_USER
export SMTP_HOST_PASSWORD
export SMTP_USE_TLS="False"
export DJANGO_LOG_URL

export POSTORIUS_TEMPLATE_BASE_URL="http://mailman-web:8000"
