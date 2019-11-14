#!/bin/bash -v

# temporary script to copy certificates into place until we can use swarm

set -e

if [ ! -f  /etc/shibboleth/sp-signing-cert.pem ] ; then
  cp -v /run/secrets/shibboleth_sp_encrypt_cert /etc/shibboleth/sp-signing-cert.pem
fi
if [ ! -f /etc/shibboleth/sp-signing-key.pem ] ; then
  cp -v /run/secrets/shibboleth_sp_encrypt_privkey /etc/shibboleth/sp-signing-key.pem
fi
chown shibd:shibd /etc/shibboleth/sp-signing-cert.pem /etc/shibboleth/sp-signing-key.pem
chmod 0400 /etc/shibboleth/sp-signing-key.pem
chmod 0444 /etc/shibboleth/sp-signing-cert.pem
ln -sf /etc/shibboleth/sp-signing-cert.pem /etc/shibboleth/sp-encrypt-cert.pem
ln -sf /etc/shibboleth/sp-signing-key.pem /etc/shibboleth/sp-encrypt-key.pem

DCC_INSTANCE=$(awk '/DCC_INSTANCE/ {print $3}' /etc/httpd/conf/httpd.conf)
cp -v /etc/letsencrypt/live/${DCC_INSTANCE}/cert.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.pem
cp -v /etc/letsencrypt/live/${DCC_INSTANCE}/privkey.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.key
cp -v /etc/letsencrypt/live/${DCC_INSTANCE}/fullchain.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.cert
chmod 0444 /etc/httpd/x509-certs/${DCC_INSTANCE}.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.cert
chmod 0400 /etc/httpd/x509-certs/${DCC_INSTANCE}.key

exit 0
