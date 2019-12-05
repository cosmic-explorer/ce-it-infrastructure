# Network configuration for host machine

We follow the [RedHat instruction for multiple
NICs](https://access.redhat.com/solutions/30564) connected to the same subnet
to configure the host machine's networking.

First install the required tools
```sh
yum -y install net-tools bind-utils NetworkManager-config-routing-rules
systemctl enable NetworkManager-dispatcher.service
start NetworkManager-dispatcher.service
```
