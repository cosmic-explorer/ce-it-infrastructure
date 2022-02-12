FROM cosmicexplorer/mailman-core-apache-shib:1

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

RUN sed -i -e "s/REQUIRE_SHIB_ATTR_MAIL/Require shib-attr mail dabrown@syr.edu\n        Require shib-attr mail bss25@psu.edu\n        Require shib-attr mail glovelace@fullerton.edu\n        Require shib-attr mail josmith@fullerton.edu\n        Require shib-attr mail jread@fullerton.edu\n        Require shib-attr mail m3v4n5@mit.edu\n        Require shib-attr mail josmith@fullerton.edu\n        Require shib-attr mail sballmer@syr.edu\n        Require shib-attr mail svitale@mit.edu\n        Require shib-attr mail dhs@mit.edu\n        Require shib-attr mail kjdaniel@brynmawr.edu\n        Require shib-attr mail jread@fullerton.edu/g" /usr/local/apache2/conf/httpd.conf

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/usr/local/etc/supervisord.conf"]
