# Network configuration for host machine

We follow the [RedHat instruction for multiple NICs](https://access.redhat.com/solutions/30564) connected to the same subnet to configure the host machine's networking.

On the machine `ce-services.phy.syr.edu`, first install the required tools
```sh
yum -y install net-tools bind-utils NetworkManager-config-routing-rules
systemctl enable NetworkManager-dispatcher.service
start NetworkManager-dispatcher.service
```

Then install these networking scripts by running the commands
```sh
cd /
git init
git remote add origin https://github.com/cosmic-explorer/ce-it-infrastructure.git
git config core.sparseCheckout true
git fetch
```

Create the file `/.git/info/sparse-checkout` containing the lines
```
etc/iproute2/*
etc/sysconfig/network-scripts/*
etc/sysctl.d/*
```

Then checkout the network configuration files with
```sh
git checkout master
and reboot the machine.
```

The routing tables should show
```
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         _gateway        0.0.0.0         UG    100    0        0 ens160
default         _gateway        0.0.0.0         UG    101    0        0 ens161
default         _gateway        0.0.0.0         UG    103    0        0 ens224
default         _gateway        0.0.0.0         UG    104    0        0 ens256
10.5.0.0        0.0.0.0         255.255.252.0   U     102    0        0 ens192
128.230.146.0   0.0.0.0         255.255.255.0   U     100    0        0 ens160
128.230.146.0   0.0.0.0         255.255.255.0   U     101    0        0 ens161
128.230.146.0   0.0.0.0         255.255.255.0   U     103    0        0 ens224
128.230.146.0   0.0.0.0         255.255.255.0   U     104    0        0 ens256
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
```
