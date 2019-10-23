#!/bin/bash -v

set -e

if [ ! -d /var/lib/mysql/dcc_docdb ] ; then
  chown mysql:mysql /var/lib/mysql
  mv /var/lib/mysql.orig/* /var/lib/mysql
fi
rm -rf /var/lib/mysql.orig

if [ ! -d /usr2/GLIMPSE ] ; then
  chown apache:apache /usr2/GLIMPSE
  chmod 1755 /usr2/GLIMPSE
  mv /usr2/GLIMPSE.orig/* /usr2/GLIMPSE
fi
rm -rf /usr2/GLIMPSE.orig

chown apache:apache /usr1/www/html/DocDB /usr1/www/html/public
if [ ! -d /usr1/www/html/DocDB/Static ] ; then
  mv /usr1/www/html/DocDB__Static /usr1/www/html/DocDB/Static
fi
if [ ! -d /usr1/www/html/public/Static ] ; then
  mv /usr1/www/html/public__Static /usr1/www/html/public/Static
fi 
rm -rf /usr1/www/html/DocDB__Static /usr1/www/html/public__Static

exit 0
