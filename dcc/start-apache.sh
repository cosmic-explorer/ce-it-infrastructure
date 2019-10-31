#!/bin/bash -v

set -e

MYSQL_ROOT_PASSWD=$(cat /run/secrets/mysql_root_passwd)
MYSQL_DOCDBRW_PASSWD=$(cat /run/secrets/mysql_docdbrw_passwd)
MYSQL_DOCDBRO_PASSWD=$(cat /run/secrets/mysql_docdbro_passwd)

sed -i -e "/db_rwpass/ s/Change.Me.too\!/${MYSQL_DOCDBRW_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/DocDB/SiteConfig.pm

DCC_INSTANCE=$(awk '/DCC_INSTANCE/ {print $3}' /etc/httpd/conf/httpd.conf)
if [ ! -f /etc/httpd/x509-certs/${DCC_INSTANCE}.pem ] ; then
  cp -v /run/secrets/https_cert_file /etc/httpd/x509-certs/${DCC_INSTANCE}.pem
fi
if [ ! -f /etc/httpd/x509-certs/${DCC_INSTANCE}.key ] ; then
  cp -v /run/secrets/https_privkey_file /etc/httpd/x509-certs/${DCC_INSTANCE}.key
fi
if [ ! -f /etc/httpd/x509-certs/${DCC_INSTANCE}.cert ] ; then
  cp -v /run/secrets/https_chain_file /etc/httpd/x509-certs/${DCC_INSTANCE}.cert
fi
chmod 0444 /etc/httpd/x509-certs/${DCC_INSTANCE}.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.cert
chmod 0400 /etc/httpd/x509-certs/${DCC_INSTANCE}.key

rm -rf /var/lib/mysql.orig
rm -rf /usr2/GLIMPSE.orig
rm -rf /usr1/www/html/DocDB__Static /usr1/www/html/public__Static

if [ ! -d /run/httpd ] ; then
  mkdir /run/httpd
fi
chown apache:apache /run/httpd/

export SHIB_HEADER_SECRET=$(cat /run/secrets/shib_header_secret)
exec $@
