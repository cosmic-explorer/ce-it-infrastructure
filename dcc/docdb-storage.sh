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

exit 0
