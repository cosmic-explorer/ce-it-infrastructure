#!/bin/bash -v

set -e

# temporary script to copy certificates into place until we can use swarm

cp /run/secrets/shibboleth_sp_encrypt_cert /etc/shibboleth/sp-signing-cert.pem
cp /run/secrets/shibboleth_sp_encrypt_privkey /etc/shibboleth/sp-signing-key.pem
chown shibd:shibd /etc/shibboleth/sp-signing-cert.pem /etc/shibboleth/sp-signing-key.pem
chmod 0400 /etc/shibboleth/sp-signing-key.pem
chmod 0444 /etc/shibboleth/sp-signing-cert.pem
ln -s /etc/shibboleth/sp-signing-cert.pem /etc/shibboleth/sp-encrypt-cert.pem
ln -s /etc/shibboleth/sp-signing-key.pem /etc/shibboleth/sp-encrypt-key.pem

cp /run/secrets/https_cert_file /etc/httpd/x509-certs/${DCC_INSTANCE}.pem
cp /run/secrets/https_privkey_file /etc/httpd/x509-certs/${DCC_INSTANCE}.key
cp /run/secrets/https_chain_file /etc/httpd/x509-certs/${DCC_INSTANCE}.cert
chown 0444 /etc/httpd/x509-certs/${DCC_INSTANCE}.pem /etc/httpd/x509-certs/${DCC_INSTANCE}.cert
chown 0400 /etc/httpd/x509-certs/${DCC_INSTANCE}.key

exit 0
