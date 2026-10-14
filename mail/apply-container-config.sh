#!/bin/bash
#
# Push the hand-maintained configuration files in this directory back into the
# running Mailman containers. See CONTAINER-CONFIG.md for what each file does.
#
# Safe to run repeatedly. Run from the mail/ directory.

set -euo pipefail
cd "$(dirname "$0")"

APACHE=mail_apache_1
POSTFIX=mail_postfix_1

echo "==> Apache: httpd.conf and cron job"
docker cp httpd.conf       ${APACHE}:/usr/local/apache2/conf/httpd.conf
docker cp restart-apache   ${APACHE}:/etc/cron.daily/restart-apache
docker exec ${APACHE} chmod +x /etc/cron.daily/restart-apache
# start.sh uncomments this at container start; do the same for a live push.
docker exec ${APACHE} sed -i -e 's/^#SSLCertificateChainFile/SSLCertificateChainFile/' /usr/local/apache2/conf/httpd.conf
docker exec ${APACHE} httpd -t
docker exec ${APACHE} apachectl graceful
echo "    Apache reloaded."

echo "==> Postfix: main.cf and recipient access map"
docker cp postfix/main.cf  ${POSTFIX}:/etc/postfix/main.cf
docker cp postfix/access   ${POSTFIX}:/etc/postfix/access
docker exec ${POSTFIX} postmap /etc/postfix/access
docker exec ${POSTFIX} postfix check
docker exec ${POSTFIX} postfix reload
echo "    Postfix reloaded."

echo "==> Done. Served certificate:"
echo | openssl s_client -servername mail.cosmicexplorer.org -connect 128.230.146.15:443 2>/dev/null \
  | openssl x509 -noout -subject -enddate
