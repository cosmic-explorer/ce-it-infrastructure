FROM cosmicexplorer/dcc-base:3.3.0

ARG DCC_INSTANCE=dcc.cosmicexplorer.org

RUN rm -f /etc/fstab && \
    passwd -d root && passwd -l root && \
    rm -f /etc/sysconfig/network-scripts/ifcfg-eth1 && \
    sed -i -e '/ligo/d;/LIGO/d;/}$/d;' /etc/krb5.conf && \
    sed -i -e '/ligo/,+5d;/Rhosts/d;' /etc/ssh/sshd_config && \
    rm -f /root/.ssh/* && \
    rm -f /etc/cron.hourly/maintain_glusterfs_mounts && \
    yum-config-manager --disable '*lscsoft*' && \
    yum -y remove puppet && \
    yum -y remove ganglia ganglia-gmond

RUN rm -f /etc/shibboleth/*pem /etc/shibboleth/*key && \
    sed -i -e s+dcc-dev.ligo.org+"${DCC_INSTANCE}"+ /etc/httpd/conf/httpd.conf && \
    sed -i -e '/VirtualHost/d;/ServerName/d;/logger/d;/SSLEngine/d;/SSLCertificate/d;/Files/d;/SSLOptions/d;/Directory/d;' /etc/httpd/conf.d/ssl.conf && \
    sed -i -e s+dcc-backup.ligo.org+"${DCC_INSTANCE}"+ /usr1/www/html/index.html && \
    sed -i -e 's+${DCC_INSTANCE}:443+_default_:443+' /etc/httpd/conf.d/dcc-dev.conf && \
    sed -i -e '/<Location \/login>/,+3d;' /etc/httpd/conf.d/dcc-dev.conf && \
    echo -e 's+</VirtualHost>+    ProxyPreserveHost On\\\n\
\\\n\
    ProxyPass /rest-dcc/ http://rest-api:8443/\\\n\
    ProxyPassReverse /rest-dcc/ http://rest-api:8443/\\\n\
   <LocationMatch "^/rest-dcc">\\\n\
       require all granted\\\n\
   </LocationMatch>\\\n\
\\\n\
    ProxyPass /oauth/ http://oauth-server:4444/\\\n\
    ProxyPassReverse /oauth/ http://oauth-server:4444/\\\n\
   <LocationMatch "^/oauth">\\\n\
       require all granted\\\n\
       RequestHeader set X-Forwarded-Proto "https"\\\n\
   </LocationMatch>\\\n\
\\\n\
   ProxyPass /consent http://oauth-consent:3000/consent\\\n\
   ProxyPassReverse /consent http://oauth-consent:3000/consent\\\n\
   <LocationMatch "^/consent">\\\n\
       require all granted\\\n\
       RequestHeader set X-Forwarded-Proto "https"\\\n\
   </LocationMatch>\\\n\
\\\n\
   ProxyPass /login http://oauth-consent:3000/login\\\n\
   ProxyPassReverse /login http://oauth-consent:3000/login\\\n\
   <LocationMatch "^/login">\\\n\
       RequestHeader set X-Forwarded-Proto "https"\\\n\
       RequestHeader set X-Shib-Remote-User %{REMOTE_USER}s\\\n\
       RequestHeader set X-Shib-Secret ${SHIB_HEADER_SECRET}\\\n\
       <RequireAll>\\\n\
           require shib-session\\\n\
           require shib-attr eduPersonPrincipalName ${REST_AUTHORIZED_EPPN}\\\n\
       </RequireAll>\\\n\
   </LocationMatch>\\\n\
\\\n\
</VirtualHost>+' | sed -i -f - /etc/httpd/conf.d/dcc-dev.conf && \
    mv /etc/httpd/conf.d/dcc.public.conf.bak /etc/httpd/conf.d/dcc.public.conf && \
    mv /etc/httpd/conf.d/short_urls.public.conf.bak /etc/httpd/conf.d/short_urls.public.conf && \
    sed -i -e "s/LIGO/CE/g" /etc/httpd/conf.d/short_urls.private.conf && \
    sed -i -e "s/LIGO/CE/g" /etc/httpd/conf.d/short_urls.public.conf && \
    sed -i -e "s+'.hostname.'.ligo.org+${DCC_INSTANCE}+" /usr1/www/cgi-bin/private/DocDB/SiteConfig.pm && \
    sed -i -e "s+'.hostname.'.ligo.org+${DCC_INSTANCE}+" /usr1/www/cgi-bin/DocDB/SiteConfig.pm && \
    sed -i -e "/\$Project/ s/LIGO/Cosmic Explorer/;" \
           -e "/\$ShortProject/ s/LIGO/CE/;" \
           -e "/DBWebMasterEmail/ s/ligo.org/cosmicexplorer.org/;" /usr1/www/cgi-bin/DocDB/ProjectGlobals.pm /usr1/www/cgi-bin/private/DocDB/ProjectGlobals.pm && \
    sed -i -e "/\$SecureMainPage/ s+\$secure_root.\"DocumentDatabase\"+\$host_name.\"Shibboleth.sso/Login?target=\".urlencode(\$host_name.\"dcc\")+;" /usr1/www/cgi-bin/private/DocDB/DocDBGlobals.pm && \
    echo -e 's|^1;$|sub urlencode {\\\n\
    my $s = shift;\\\n\
    $s =~ s/ /+/g;\\\n\
    $s =~ s/([^A-Za-z0-9\+-])/sprintf("%%%02X", ord($1))/seg;\\\n\
    return $s;\\\n\
}\\\n\
\\\n\
1;|' | sed -i -f - /usr1/www/cgi-bin/private/DocDB/Utilities.pm && \
    rm -rf /usr1/www/html/login && \
    rm -rf  /etc/httpd/conf.d/shibboleth-ds.conf && \
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

RUN curl http://download.opensuse.org/repositories/security://shibboleth/CentOS_7/security:shibboleth.repo > /etc/yum.repos.d/shibboleth.repo && \
    yum install -y shibboleth-embedded-ds && \
    find='[ "^https:\/\/example\.org\/Shibboleth\.sso\/Login.*$" , "^https:\/\/example\.com\/Shibboleth\.sso\/Login.*$" ];' && \
    find_esc=$(sed 's/[^^]/[&]/g; s/\^/\\^/g' <<<"${find}") && \
    replace='[ "^https:\\/\\/.*\\.phy\\.syr\\.edu\\/Shibboleth\\.sso\\/Login.*$" , "^https:\\/\\/.*\\.cosmicexplorer\\.org\\/Shibboleth\\.sso\\/Login.*$" ];' && \
    sed -i -e "s+${find_esc}+${replace}+g" /etc/shibboleth-ds/idpselect_config.js && \
    sed -i -e '$r /etc/shibboleth-ds/shibboleth-ds.conf' /etc/httpd/conf.d/dcc-dev.conf && \
    rm -f /etc/httpd/conf.d/shibboleth-ds.conf && \
    sed -i -e 's/IDP select test bed/Cosmic Explorer Identity Selector/g' /etc/shibboleth-ds/index.html && \
    sed -i -e '/<noscript>/,/<\/noscript>/{/<noscript>/!{/<\/noscript>/!d;};}' /etc/shibboleth-ds/index.html && \
    echo -e 's+<body>+<body>\\\n\
\\\n\
<h1>Cosmic Explorer Identity Provider Selection Service</h1>\\\n\
<h2>Please select an identity provider to login</h2>\\\n\
\\\n\
<h3>Choose an identity provider from the options in the box below</h3>\\\n\
\\\n\
<p>The first time that you log in, you should pick from the list or enter an or organization name. Your previous choice(s) will be suggested on future visits, or you can select a different provider from the list below.</p>\\\n\
\\\n\
<h3>Which provider should I choose?</h3>\\\n\
\\\n\
<ul>\\\n\
<li> If your home institution is available in the list below, select that provider.\\\n\
<li> If your home institution is not listed and you are an LSC/Virgo/Kagra collaboration member, then you can select one of the LIGO Identity providers and log in with your LIGO.ORG credentials. Information on managing these credentials is available at <a href="https://my.ligo.org">my.ligo.org</a>.\\\n\
<li> If your institution is not listed and you are not an LSC/Virgo/Kagra collaboration member, please contact <a href="mailto:help@cosmicexplorer.org">help@cosmicexplorer.org</a> for assistance.\\\n\
</ul>\\\n\
\\\n+' | sed -i -f - /etc/shibboleth-ds/index.html

COPY supervisord.conf /usr/local/etc/supervisord.conf
COPY start-shibd.sh /usr/local/sbin/start-shibd.sh
COPY start-apache.sh /usr/local/sbin/start-apache.sh

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/usr/local/etc/supervisord.conf"]
