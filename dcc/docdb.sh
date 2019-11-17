#!/bin/bash -v

set -e

MYSQL_ROOT_PASSWD=$(cat /run/secrets/mysql_root_passwd)
MYSQL_DOCDBRW_PASSWD=$(cat /run/secrets/mysql_docdbrw_passwd)
MYSQL_DOCDBRO_PASSWD=$(cat /run/secrets/mysql_docdbro_passwd)

if [ ! -f /var/lib/mysql/docdb.init ] ; then
mysql -u root << EOF
USE dcc_docdb;
DELETE FROM \`SecurityGroup\` WHERE GroupID <> 1 AND GroupID <> 3;
INSERT INTO \`SecurityGroup\` VALUES(2, 'CO:admins', 'Administrators', CURRENT_TIMESTAMP, 1, 1, 1, 1, '1');
INSERT INTO \`SecurityGroup\` VALUES(4, 'CEPIs', 'Cosmic Explorer PIs and CoPIs', CURRENT_TIMESTAMP, 1, 0, 1, 0, '1');
INSERT INTO \`SecurityGroup\` VALUES(5, 'CEProject', 'Cosmic Explorer Project', CURRENT_TIMESTAMP, 1, 0, 1, 0, '1');
INSERT INTO \`SecurityGroup\` VALUES(6, 'CEConsortium', 'Cosmic Explorer Consortium', CURRENT_TIMESTAMP, 0, 0, 1, 0, '1');
INSERT INTO \`SecurityGroup\` VALUES(7, 'NSF', 'Cosmic Explorer NSF Program Officers', CURRENT_TIMESTAMP, 1, 0, 1, 0, '1');
DELETE FROM \`GroupHierarchy\`;
INSERT INTO \`GroupHierarchy\` VALUES(1, 101, 100, CURRENT_TIMESTAMP);
INSERT INTO \`GroupHierarchy\` VALUES(2, 102, 100, CURRENT_TIMESTAMP);
INSERT INTO \`GroupHierarchy\` VALUES(3, 102, 101, CURRENT_TIMESTAMP);
DELETE FROM \`Institution\`;
INSERT INTO \`Institution\` VALUES(1, 'CEConsortium', 'Cosmic Explorer Consortium', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(2, 'Caltech', 'California Institute Of Technology', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(3, 'CSUF', 'California State University Fullerton', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(4, 'MIT', 'Massachusetts Institute Of Technology', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(5, 'PennState', 'Penn State University', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(6, 'NSF', 'National Science Foundation', CURRENT_TIMESTAMP);
INSERT INTO \`Institution\` VALUES(7, 'SU', 'Syracuse University', CURRENT_TIMESTAMP);
DELETE FROM \`AuthorGroupDefinition\`;
INSERT INTO \`AuthorGroupDefinition\` VALUES(1, 'CEProject', 'Cosmic Explorer Project');
INSERT INTO \`AuthorGroupDefinition\` VALUES(2, 'CEConsortium', 'Cosmic Explorer Consortium');
DELETE FROM \`EventGroup\`;
INSERT INTO \`EventGroup\` VALUES(1, 'Project Team Meetings', 'Project Team Meetings', CURRENT_TIMESTAMP);
INSERT INTO \`EventGroup\` VALUES(2, 'Consortium Meetings', 'Consortium Meetings', CURRENT_TIMESTAMP);
DELETE FROM \`EventTopic\`;
EOF
mysql -u root << EOF
GRANT USAGE ON *.* TO 'docdbrw'@'%';
GRANT USAGE ON *.* TO 'docdbro'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON dcc_docdb.* TO 'docdbrw'@'%';
GRANT SELECT ON dcc_docdb.* TO 'docdbro'@'%';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWD}');
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('${MYSQL_ROOT_PASSWD}');
SET PASSWORD FOR 'docdbrw'@'localhost' = PASSWORD('${MYSQL_DOCDBRW_PASSWD}');
SET PASSWORD FOR 'docdbro'@'localhost' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
SET PASSWORD FOR 'docdbrw'@'%' = PASSWORD('${MYSQL_DOCDBRW_PASSWD}');
SET PASSWORD FOR 'docdbro'@'%' = PASSWORD('${MYSQL_DOCDBRO_PASSWD}');
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
