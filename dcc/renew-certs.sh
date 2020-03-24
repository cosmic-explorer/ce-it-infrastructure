#!/bin/bash

set -x

DCC_INSTANCE=$(awk '/DCC_INSTANCE/ {print $3}' /etc/httpd/conf/httpd.conf)
cp -v /etc/letsencrypt/live/${DCC_INSTANCE}/cert.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.pem
cp -v /etc/letsencrypt/live/${DCC_INSTANCE}/privkey.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.key
cp -v /etc/letsencrypt/live/${DCC_INSTANCE}/fullchain.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.cert
chmod 0444 /etc/httpd/x509-certs/${DCC_INSTANCE}.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.cert
chmod 0400 /etc/httpd/x509-certs/${DCC_INSTANCE}.key

httpd -k graceful

exit 0
