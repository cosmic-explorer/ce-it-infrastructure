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
INSERT INTO \`DocumentType\` VALUES(16, 'N - Funding proposals', 'Proposals to funding agencies (federal or private foundation)', CURRENT_TIME, 1);
UPDATE \`DocumentType\` SET NextDocNumber = 1;
UPDATE \`DocumentType\` SET LongType = 'Serial Numbers for Cosmic Explorer Equipment' WHERE DocTypeID=9;
DELETE from \`TopicHint\`;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Astrophysics' WHERE \`TopicID\` = 4;
UPDATE \`Topic\` SET \`LongDescription\` = 'Astrophysics' WHERE \`TopicID\` = 4;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Advisory Boards' WHERE \`TopicID\` = 32;
UPDATE \`Topic\` SET \`LongDescription\` = 'Advisory Boards' WHERE \`TopicID\` = 32;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Nuclear Physics' WHERE \`TopicID\` = 46;
UPDATE \`Topic\` SET \`LongDescription\` = 'Nuclear Physics' WHERE \`TopicID\` = 46;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Neutron Stars' WHERE \`TopicID\` = 48;
UPDATE \`Topic\` SET \`LongDescription\` = 'Neutron Stars' WHERE \`TopicID\` = 48;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Black Holes' WHERE \`TopicID\` = 49;
UPDATE \`Topic\` SET \`LongDescription\` = 'Black Holes' WHERE \`TopicID\` = 49;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Compact-Object Binaries' WHERE \`TopicID\` = 50;
UPDATE \`Topic\` SET \`LongDescription\` = 'Compact-Object Binaries' WHERE \`TopicID\` = 50;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Unmodeled Bursts' WHERE \`TopicID\` = 51;
UPDATE \`Topic\` SET \`LongDescription\` = 'Unmodeled Bursts' WHERE \`TopicID\` = 51;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Fundamental Physics' WHERE \`TopicID\` = 55;
UPDATE \`Topic\` SET \`LongDescription\` = 'Fundamental Physics' WHERE \`TopicID\` = 55;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Diversity and Inclusion' WHERE \`TopicID\` = 59;
UPDATE \`Topic\` SET \`LongDescription\` = 'Diversity and Inclusion' WHERE \`TopicID\` = 59;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Multimessenger' WHERE \`TopicID\` = 63;
UPDATE \`Topic\` SET \`LongDescription\` = 'Multimessenger' WHERE \`TopicID\` = 63;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Site Selection' WHERE \`TopicID\` = 66;
UPDATE \`Topic\` SET \`LongDescription\` = 'Site Selection' WHERE \`TopicID\` = 66;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Rates and Populations' WHERE \`TopicID\` = 72;
UPDATE \`Topic\` SET \`LongDescription\` = 'Rates and Populations' WHERE \`TopicID\` = 72;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Cosmology' WHERE \`TopicID\` = 76;
UPDATE \`Topic\` SET \`LongDescription\` = 'Cosmology' WHERE \`TopicID\` = 76;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Waveform Modeling' WHERE \`TopicID\` = 81;
UPDATE \`Topic\` SET \`LongDescription\` = 'Waveform Modeling' WHERE \`TopicID\` = 81;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Data-Analysis Methods' WHERE \`TopicID\` = 84;
UPDATE \`Topic\` SET \`LongDescription\` = 'Data-Analysis Methods' WHERE \`TopicID\` = 84;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Supernovae' WHERE \`TopicID\` = 88;
UPDATE \`Topic\` SET \`LongDescription\` = 'Supernovae' WHERE \`TopicID\` = 88;
UPDATE \`Topic\` SET \`ShortDescription\` = 'Analysis' WHERE \`TopicID\` = 89;
UPDATE \`Topic\` SET \`LongDescription\` = 'Analysis' WHERE \`TopicID\` = 89;
INSERT INTO \`Topic\` VALUES(90, 'Cryogenics', 'Cryogenics', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(91, 'Coatings', 'Coatings', CURRENT_TIMESTAMP);
INSERT INTO \`Topic\` VALUES(92, 'Substrates', 'Substrates', CURRENT_TIMESTAMP);
UPDATE \`TopicHierarchy\` SET \`ParentTopicID\` = 1 WHERE \`TopicID\` = 47;
UPDATE \`TopicHierarchy\` SET \`ParentTopicID\` = 1 WHERE \`TopicID\` = 54;
UPDATE \`TopicHierarchy\` SET \`ParentTopicID\` = 1 WHERE \`TopicID\` = 66;
UPDATE \`TopicHierarchy\` SET \`ParentTopicID\` = 1 WHERE \`TopicID\` = 70;
UPDATE \`TopicHierarchy\` SET \`ParentTopicID\` = 3 WHERE \`TopicID\` = 74;
UPDATE \`TopicHierarchy\` SET \`ParentTopicID\` = 4 WHERE \`TopicID\` = 72;
UPDATE \`TopicHierarchy\` SET \`ParentTopicID\` = 4 WHERE \`TopicID\` = 76;
UPDATE \`TopicHierarchy\` SET \`ParentTopicID\` = 4 WHERE \`TopicID\` = 81;
UPDATE \`TopicHierarchy\` SET \`ParentTopicID\` = 4 WHERE \`TopicID\` = 84;
INSERT INTO \`TopicHierarchy\` VALUES (84, 90, 1, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (85, 91, 1, CURRENT_TIMESTAMP);
INSERT INTO \`TopicHierarchy\` VALUES (86, 92, 1, CURRENT_TIMESTAMP);
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
sed -i "s/dcc.ligo.org/dcc.cosmicexplorer.org/g" /usr1/www/cgi-bin/DocDB/Search

exit 0
