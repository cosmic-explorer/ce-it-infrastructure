FROM sugwg/dcc-base:latest
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

ARG DCC_INSTANCE=dcc.cosmicexplorer.org

COPY certificates.sh /usr/local/sbin/certificates.sh
COPY certificates.service /lib/systemd/system/certificates.service

RUN rm -f /etc/fstab && \
    passwd -d root && passwd -l root && \
    rm -f /etc/sysconfig/network-scripts/ifcfg-eth1 && \
    sed -i -e '/ligo/d;/LIGO/d;/}$/d;' /etc/krb5.conf && \
    sed -i -e '/ligo/,+5d;/Rhosts/d;' /etc/ssh/sshd_config && \
    rm -f /root/.ssh/* && \
    rm -f /etc/cron.hourly/maintain_glusterfs_mounts && \
    rpm -e puppet && \
    rpm -e ganglia ganglia-gmond

RUN systemctl enable certificates.service && \
    rm -f /etc/shibboleth/*pem /etc/shibboleth/*key && \
    systemctl enable shibd.service && \
    sed -i -e s+dcc-dev.ligo.org+"${DCC_INSTANCE}"+ /etc/httpd/conf/httpd.conf && \
    sed -i -e '/VirtualHost/d;/ServerName/d;/logger/d;/SSLEngine/d;/SSLCertificate/d;/Files/d;/SSLOptions/d;/Directory/d;' /etc/httpd/conf.d/ssl.conf && \
    sed -i -e s+dcc-backup.ligo.org+"${DCC_INSTANCE}"+ /usr1/www/html/index.html && \
    sed -i -e 's+${DCC_INSTANCE}:443+_default_:443+' /etc/httpd/conf.d/dcc-dev.conf && \
    mv /etc/httpd/conf.d/dcc.public.conf.bak /etc/httpd/conf.d/dcc.public.conf && \
    rm -f  /etc/httpd/conf.d/mediawiki.conf && \
    rm -f /etc/httpd/conf.d/awstats.conf.rpmnew && \
    rm -rf /etc/awstats /usr1/www/cgi-bin/awstats /usr1/www/html/icon/other/awstats* /var/lib/awstats && \
    systemctl enable httpd.service

COPY docdb.service /lib/systemd/system/docdb.service
COPY docdb.sh /usr/local/sbin/docdb.sh

RUN mv /var/lib/mysql /var/lib/mysql.orig && \
    mkdir /var/lib/mysql && \
    chown mysql:mysql /var/lib/mysql && \
    systemctl enable mariadb.service && \
    systemctl enable docdb.service && \
    sed -i 79,104d /usr1/www/cgi-bin/DocDB/DocumentDatabase && \
    ln -s /usr1/www/html/DocDB/Static/css/LIGODocDB.css.dcc-dev-private /usr1/www/html/DocDB/Static/css/CEDocDB.css && \
    ln -s /usr1/www/html/public/Static/css/LIGODocDB.css.dcc-dev-private /usr1/www/html/public/Static/css/CEDocDB.css && \
    sed -i -e '/WikiInstructions/d; /Using the DCC/d; /Other DCC Projects/,+6d;' /usr1/www/cgi-bin/private/DocDB/DocumentDatabase && \
    mv /usr1/www/html/DocDB/Static /usr1/www/html/DocDB__Static && \
    mv /usr1/www/html/public/Static /usr1/www/html/public__Static

CMD ["/usr/sbin/init"]
