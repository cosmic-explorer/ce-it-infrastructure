#!/bin/bash -v

set -e

MYSQL_ROOT_PASSWD=$(cat /run/secrets/mysql_root_passwd)
MYSQL_DOCDBRW_PASSWD=$(cat /run/secrets/mysql_docdbrw_passwd)
MYSQL_DOCDBRO_PASSWD=$(cat /run/secrets/mysql_docdbro_passwd)

mysql -u root << EOF
USE dcc_docdb;
INSERT INTO \`Author\` VALUES (1,'Duncan',NULL,'Brown',50,1,'2019-01-30','dabrown','Duncan Brown');
INSERT INTO \`RemoteUser\` VALUES (1,'dabrown@syr.edu',1,'dabrown@syr.edu');
INSERT INTO \`EmailUser\` VALUES (1,'dabrown','','Duncan Brown','dabrown@syr.edu',0,'2019-01-30',1,1,1,1);
INSERT INTO \`UsersGroup\` VALUES (1,1,45,'2019-01-30');
EOF

mysql -u root << EOF
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWD}');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('${MYSQL_ROOT_PASSWD}');
SET PASSWORD FOR 'docdbrw'@'localhost' = PASSWORD('${MYSQL_DOCDBRW_PASSWD}');
SET PASSWORD FOR 'docdbro'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
SET PASSWORD FOR 'wikiuser'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
SET PASSWORD FOR 'wikidb_restore'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
FLUSH PRIVILEGES;
EOF

sed -i -e "/db_rwpass/ s/Change.Me.too\!/${MYSQL_DOCDBRW_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/DocDB/SiteConfig.pm

DCC_INSTANCE=$(awk '/DCC_INSTANCE/ {print $3}' /etc/httpd/conf/httpd.conf)
sed -i -e "s+'.hostname.'.ligo.org+${DCC_INSTANCE}+" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "s+'.hostname.'.ligo.org+${DCC_INSTANCE}+" /usr1/www/cgi-bin/DocDB/SiteConfig.pm

for config_file in /usr1/www/cgi-bin/DocDB/ProjectGlobals.pm /usr1/www/cgi-bin/private/DocDB/ProjectGlobals.pm ; do
  sed -i -e "/\$Project/ s/LIGO/Cosmic Explorer/;" \
         -e "/\$ShortProject/ s/LIGO/CE/;" \
         -e "/DBWebMasterEmail/ s/ligo.org/cosmicexplorer.org/;" ${config_file}
done

chown apache:apache /usr1/www/html/DocDB /usr1/www/html/public
mv /usr1/www/html/DocDB__Static /usr1/www/html/DocDB/Static
mv /usr1/www/html/public__Static /usr1/www/html/public/Static
