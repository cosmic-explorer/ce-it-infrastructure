ARG COMANAGE_REGISTRY_VERSION=develop
ARG COMANAGE_REGISTRY_SHIBBOLETH_SP_IMAGE_VERSION=1

FROM comanage-registry:${COMANAGE_REGISTRY_VERSION}-shibboleth-sp-${COMANAGE_REGISTRY_SHIBBOLETH_SP_IMAGE_VERSION}

RUN apt-get -y install vim git iproute2
RUN cd /srv/comanage-registry && \
    git init && \
    git remote add origin https://github.com/cosmic-explorer/comanage-registry.git && \
    git fetch --all && \
    git config core.sparseCheckout true && \
    echo "app/AvailablePlugin/GithubProvisioner/*" > .git/info/sparse-checkout && \
    echo "app/AvailablePlugin/RestDccProvisioner/*" >> .git/info/sparse-checkout && \
    rm -rf app/AvailablePlugin/GithubProvisioner && \
    git checkout master
    
RUN ln -sf /etc/letsencrypt/live/roster.cosmicexplorer.org/cert.pem /etc/apache2/cert.pem && \
    ln -sf /etc/letsencrypt/live/roster.cosmicexplorer.org/privkey.pem /etc/apache2/privkey.pem && \
    ln -sf /etc/letsencrypt/live/roster.cosmicexplorer.org/fullchain.pem /etc/apache2/ca-chain.pem

COPY restart-apache /etc/cron.daily/restart-apache
RUN chmod +x /etc/cron.daily/restart-apache

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/usr/local/etc/supervisord.conf"]
