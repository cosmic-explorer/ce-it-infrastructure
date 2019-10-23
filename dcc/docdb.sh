#!/bin/bash -v

MYSQL_ROOT_PASSWD=$(cat /run/secrets/mysql_root_passwd)
MYSQL_DOCDBRW_PASSWD=$(cat /run/secrets/mysql_docdbrw_passwd)
MYSQL_DOCDBRO_PASSWD=$(cat /run/secrets/mysql_docdbro_passwd)

mysql -u root << EOF
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWD}');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('${MYSQL_ROOT_PASSWD}');
SET PASSWORD FOR 'docdbrw'@'localhost' = PASSWORD('${MYSQL_DOCDBRW_PASSWD}');
SET PASSWORD FOR 'docdbro'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
SET PASSWORD FOR 'wikiuser'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
SET PASSWORD FOR 'wikidb_restore'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
FLUSH PRIVILEGES;
EOF
