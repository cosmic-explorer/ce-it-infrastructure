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

ARG DCC_INSTANCE=seaview.phy.syr.edu

RUN passwd -l root && \
    rm -f /etc/sysconfig/network-scripts/ifcfg-eth1 && \
    sed -e s+dcc-dev.ligo.org+"${DCC_INSTANCE}"+ /etc/httpd/conf/httpd.conf > /etc/httpd/conf/httpd.conf.tmp && \
    mv /etc/httpd/conf/httpd.conf.tmp /etc/httpd/conf/httpd.conf

CMD ["/usr/sbin/init"]
