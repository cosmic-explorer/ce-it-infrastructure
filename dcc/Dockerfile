FROM cosmicexplorer/dcc-base:3.3.0

ARG DCC_INSTANCE=dcc.cosmicexplorer.org

RUN rm -f /etc/fstab && \
    passwd -d root && passwd -l root && \
    rm -f /etc/sysconfig/network-scripts/ifcfg-eth1 && \
    sed -i -e '/ligo/d;/LIGO/d;/}$/d;' /etc/krb5.conf && \
    sed -i -e '/ligo/,+5d;/Rhosts/d;' /etc/ssh/sshd_config && \
    rm -f /root/.ssh/* && \
    rm -f /etc/cron.hourly/maintain_glusterfs_mounts && \
    yum -y remove puppet && \
    yum -y remove ganglia ganglia-gmond

RUN rm -f /etc/shibboleth/*pem /etc/shibboleth/*key && \
    sed -i -e s+dcc-dev.ligo.org+"${DCC_INSTANCE}"+ /etc/httpd/conf/httpd.conf && \
    sed -i -e '/VirtualHost/d;/ServerName/d;/logger/d;/SSLEngine/d;/SSLCertificate/d;/Files/d;/SSLOptions/d;/Directory/d;' /etc/httpd/conf.d/ssl.conf && \
    sed -i -e s+dcc-backup.ligo.org+"${DCC_INSTANCE}"+ /usr1/www/html/index.html && \
    sed -i -e 's+${DCC_INSTANCE}:443+_default_:443+' /etc/httpd/conf.d/dcc-dev.conf && \
    printf 's+</VirtualHost>+    ProxyPreserveHost On\
\
    ProxyPass /rest-dcc/ http://rest-api:8443/\
    ProxyPassReverse /rest-dcc/ http://rest-api:8443/\
\
   <LocationMatch "^/rest-dcc">\
       require all granted\
   </LocationMatch>\
\
    ProxyPass /oauth/ http://oauth-server:4444/\
    ProxyPassReverse /oauth/ http://oauth-server:4444/\
\
   <LocationMatch "^/oauth">\
       require all granted\
       RequestHeader set X-Forwarded-Proto "https"\
   </LocationMatch>\
\
</VirtualHost>+' | sed -i -f -  /etc/httpd/conf.d/dcc-dev.conf && \
    mv /etc/httpd/conf.d/dcc.public.conf.bak /etc/httpd/conf.d/dcc.public.conf && \
    mv /etc/httpd/conf.d/short_urls.public.conf.bak /etc/httpd/conf.d/short_urls.public.conf && \
    sed -i -e "s/LIGO/CE/g" /etc/httpd/conf.d/short_urls.private.conf && \
    sed -i -e "s/LIGO/CE/g" /etc/httpd/conf.d/short_urls.public.conf && \
    sed -i -e "s+'.hostname.'.ligo.org+${DCC_INSTANCE}+" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm && \
    sed -i -e "s+'.hostname.'.ligo.org+${DCC_INSTANCE}+" /usr1/www/cgi-bin/DocDB/SiteConfig.pm && \
    sed -i -e "/\$Project/ s/LIGO/Cosmic Explorer/;" \
           -e "/\$ShortProject/ s/LIGO/CE/;" \
           -e "/DBWebMasterEmail/ s/ligo.org/cosmicexplorer.org/;" /usr1/www/cgi-bin/DocDB/ProjectGlobals.pm /usr1/www/cgi-bin/private/DocDB/ProjectGlobals.pm && \
    rm -f  /etc/httpd/conf.d/mediawiki.conf && \
    rm -f /etc/httpd/conf.d/awstats.conf.rpmnew && \
    rm -rf /etc/awstats /usr1/www/cgi-bin/awstats /usr1/www/html/icon/other/awstats* /var/lib/awstats

RUN mv /var/lib/mysql /var/lib/mysql.orig && \
    mkdir /var/lib/mysql && \
    chown mysql:mysql /var/lib/mysql && \
    sed -i 79,104d /usr1/www/cgi-bin/DocDB/DocumentDatabase && \
    ln -s /usr1/www/html/DocDB/Static/css/LIGODocDB.css.dcc-dev-private /usr1/www/html/DocDB/Static/css/CEDocDB.css && \
    ln -s /usr1/www/html/public/Static/css/LIGODocDB.css.dcc-dev-private /usr1/www/html/public/Static/css/CEDocDB.css && \
    sed -i -e '/WikiInstructions/d; /Using the DCC/d; /Other DCC Projects/,+6d;' /usr1/www/cgi-bin/private/DocDB/DocumentDatabase && \
    mv /usr1/www/html/DocDB/Static /usr1/www/html/DocDB__Static && \
    mv /usr1/www/html/public/Static /usr1/www/html/public__Static && \
    mv /usr2/GLIMPSE /usr2/GLIMPSE.orig && \
    mkdir /usr2/GLIMPSE && \
    chown apache:apache /usr2/GLIMPSE && \
    chmod 1755 /usr2/GLIMPSE

RUN yum -y install yum-plugin-ovl supervisor

RUN sed -i -e "/\$db_host/ s/localhost/docdb-database/;" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm /usr1/www/cgi-bin/DocDB/SiteConfig.pm && \
    sed -i -e 's/localhost/smtp-host.syr.edu/' /usr1/www/cgi-bin/private/DocDB/Utilities.pm /usr1/www/cgi-bin/DocDB/Utilities.pm

COPY supervisord.conf /usr/local/etc/supervisord.conf
COPY start-shibd.sh /usr/local/sbin/start-shibd.sh
COPY start-apache.sh /usr/local/sbin/start-apache.sh

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/usr/local/etc/supervisord.conf"]
