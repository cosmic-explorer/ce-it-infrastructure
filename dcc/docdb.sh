#!/bin/bash -v

set -e

MYSQL_ROOT_PASSWD=$(cat /run/secrets/mysql_root_passwd)
MYSQL_DOCDBRW_PASSWD=$(cat /run/secrets/mysql_docdbrw_passwd)
MYSQL_DOCDBRO_PASSWD=$(cat /run/secrets/mysql_docdbro_passwd)

if [ ! -f /var/lib/mysql/docdb.init ] ; then
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
touch /var/lib/mysql/docdb.init
fi

sed -i -e "/db_rwpass/ s/Change.Me.too\!/${MYSQL_DOCDBRW_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm
sed -i -e "/db_ropass/ s/Change.Me.too\!/${MYSQL_DOCDBRO_PASSWD}/;" /usr1/www/cgi-bin/DocDB/SiteConfig.pm

exit 0