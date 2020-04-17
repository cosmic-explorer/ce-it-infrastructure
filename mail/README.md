# Cosmic Explorer Mailman Instance

These instructions are a guide for setting up [GNU Mailman](https://www.list.org/) for the Cosmic
Explorer Consortium.

## Install Instructions

To build and deploy Mailman, first download a copy of the
[comanage-registry-docker](https://github.com/Internet2/comanage-registry-docker/)
repository into this directory.  There are serveral outsiding pull requests
that are needed which have not yet been merged to master so the Cosmic Explorer
[fork](https://github.com/cosmic-explorer/comanage-registry-docker) of this
repository should be used until the patches are merged.  This can be obtained
by by running the commands
```sh
git clone https://github.com/cosmic-explorer/comanage-registry-docker.git
```

Edit the file `mailman-env.sh` to set the environment variables to the appropriate values for the installation. The various 
`PASSWD` and `SECRET` variables should be set to real passwords generated, for example, by
```sh
export LC_CTYPE=C; cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

Run the build script by running the command
```sh
. build-mailman.sh
```

## Container Management

### Starting the Containers

Set up the envrionment by running
```sh
./run-mailman.sh
```
Once the script has run, watch the logs of the apache container with the command
```sh
docker logs -f mail_apache_1
```
This will print `Waiting for Mailman web container...` until the mailman services are up and then will print
```
AH00489: Apache/2.4.38 (Unix) OpenSSL/1.1.0j configured -- resuming normal operations
AH00094: Command line: 'httpd -D FOREGROUND'
```
once the web server is running. Note that it can take several minutes for Shibboleth to download and check all the IdP metadata before apache will accept connections. You can watch the `shibd` process with
```sh
docker exec -it mail_apache_1 top
```
Once `shibd` goes from running to sleeping, the server should be ready.

Once all the services are up and running, browse to https://mail.cosmicexplorer.org/ and log in with Shibboleth.

### Additional apache configuration

The mailing list archives are configured so that anyone with a valid Shibboleth session can access them. This will allow anyone in InCommon R&S to access the archives. To prevent this, edit the file `/usr/local/apache2/conf/httpd.conf` and in the `<Location "/hyperkitty/">` directive, change `Require shib-session` to `Require shib-attr mail ${MAILMAN_ADMIN_EMAIL}`.

The certificate, key, and chain used by apache are copied in place by the setup files. This means that the certificate will eventaully expire as apache does not see the refreshed Let's Encrypt certificate. To work around this, make the certificate files symbolic links to the Let's Encrypt versions by running the commands
```sh
ln -sf /etc/letsencrypt/live/mail.cosmicexplorer.org/cert.pem /usr/local/apache2/conf/server.crt
ln -sf /etc/letsencrypt/live/mail.cosmicexplorer.org/privkey.pem /usr/local/apache2/conf/server.key
ln -sf /etc/letsencrypt/live/mail.cosmicexplorer.org/fullchain.pem /usr/local/apache2/conf/ca-chain.crt
```
Apache needs to be restarted to pick up changes in the certificates, so create an executable file `/etc/cron.daily/restart-apache` to restart apache by running the commands
```sh
cat > /etc/cron.daily/restart-apache <<EOF
#!/bin/sh
/usr/local/apache2/bin/httpd -k graceful
EOF
chmod +x /etc/cron.daily/restart-apache
/etc/cron.daily/restart-apache
```
which will trigger a daily graceful reload of apache.

### Stopping the containers 

Stop the containers with
```sh
./stop-mailman.sh
```

## Connecting COmanage to Mailman

To allow COmanage to create mailing lists, first create a new provisioning target for mailman

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/mail/create-provisioning-target.png" width="275">

Configure this provisioning to talk to the REST API on `http://mailman-core:8001` using the `MAILMAN_REST_PASSWORD` set in `mailman-env.sh`. 

<img src="https://raw.githubusercontent.com/cosmic-explorer/ce-it-infrastructure/master/mail/configure-provisioning-target.png" width="275">

Once this is set up, lists can be created and deleted with the email lists feature in COmanage.
