#!/bin/bash -v

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

if [ ! -d /run/shibboleth ] ; then
  mkdir -p /run/shibboleth
fi
chown shibd:shibd /run/shibboleth

export LD_LIBRARY_PATH=/opt/shibboleth/lib64
exec /usr/sbin/shibd -f -u shibd -g shibd -c /etc/shibboleth/shibboleth2.xml -p /var/run/shibboleth/shibd.pid -F -w 600
