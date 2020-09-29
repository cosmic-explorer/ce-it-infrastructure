#!/bin/bash -v

set -e

MYSQL_ROOT_PASSWD=$(cat /run/secrets/mysql_root_passwd)
MYSQL_DOCDBRW_PASSWD=$(cat /run/secrets/mysql_docdbrw_passwd)
MYSQL_DOCDBRO_PASSWD=$(cat /run/secrets/mysql_docdbro_passwd)

sed -i -e "/db_rwpass/ s/Change.Me.too\!/${MYSQL_DOCDBRW_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/DocDB/SiteConfig.pm

DCC_INSTANCE=$(awk '/DCC_INSTANCE/ {print $3}' /etc/httpd/conf/httpd.conf)
ln -sf /etc/letsencrypt/live/${DCC_INSTANCE}/cert.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.pem
ln -sf /etc/letsencrypt/live/${DCC_INSTANCE}/privkey.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.key
ln -sf /etc/letsencrypt/live/${DCC_INSTANCE}/fullchain.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.cert

rm -rf /var/lib/mysql.orig
rm -rf /usr2/GLIMPSE.orig
rm -rf /usr1/www/html/DocDB__Static /usr1/www/html/public__Static

if [ ! -d /run/httpd ] ; then
  mkdir /run/httpd
fi
chown apache:apache /run/httpd/

export SHIB_HEADER_SECRET=$(cat /run/secrets/shib_header_secret)
export REST_AUTHORIZED_EPPN=$(cat /run/secrets/rest_authorized_eppn)
exec $@
