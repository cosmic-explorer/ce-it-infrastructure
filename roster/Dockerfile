ARG COMANAGE_REGISTRY_VERSION=develop
ARG COMANAGE_REGISTRY_SHIBBOLETH_SP_IMAGE_VERSION=1

FROM comanage-registry:${COMANAGE_REGISTRY_VERSION}-shibboleth-sp-${COMANAGE_REGISTRY_SHIBBOLETH_SP_IMAGE_VERSION}

RUN apt-get -y install vim git iproute2 cron
RUN cd /srv/comanage-registry && \
    git init && \
    git remote add origin https://github.com/cosmic-explorer/comanage-registry.git && \
    git fetch --all && \
    git config core.sparseCheckout true && \
    echo "app/AvailablePlugin/RestDccProvisioner/*" >> .git/info/sparse-checkout && \
    git checkout master
    
COPY restart-apache /etc/cron.daily/restart-apache
RUN chmod +x /etc/cron.daily/restart-apache

RUN /bin/echo -e "\n\
[program:cron]\n\
command=/usr/sbin/cron -f\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n" >> /usr/local/etc/supervisord.conf

COPY lang.php /srv/comanage-registry/app/Lib/lang.php
RUN chmod 664 /srv/comanage-registry/app/Lib/lang.php

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/usr/local/etc/supervisord.conf"]
