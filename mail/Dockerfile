FROM cosmicexplorer/mailman-core-apache-shib:1

RUN apt-get -y --allow-releaseinfo-change update
RUN apt-get -y install cron openssl ca-certificates
    
COPY restart-apache /etc/cron.daily/restart-apache
RUN chmod +x /etc/cron.daily/restart-apache

RUN /bin/echo -e "\n\
[program:cron]\n\
command=/usr/sbin/cron -f\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n" >> /usr/local/etc/supervisord.conf

# Full Apache config captured from the running container on 2026-10-14
# (replaces the earlier sed-based REQUIRE_SHIB_ATTR_MAIL substitution).
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/usr/local/etc/supervisord.conf"]
