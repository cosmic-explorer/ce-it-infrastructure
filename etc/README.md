# Network configuration for host machine

## Introduction

Ideally, we would use [macvlan networks](https://docs.docker.com/network/macvlan/) within docker to generate virtual interfaces witin a Docker [swarm network](https://neuvector.com/network-security/docker-swarm-container-networking/) that we can assign physical IPs to. However, this needs VETT to enable [promiscuous mode](https://docs.vmware.com/en/VMware-vSphere/6.0/com.vmware.vsphere.security.doc/GUID-92F3AB1F-B4C5-4F25-A010-8820D7250350.html) and allow [forged transmits](https://docs.vmware.com/en/VMware-vSphere/6.0/com.vmware.vsphere.security.doc/GUID-7DC6486F-5400-44DF-8A62-6273798A2F80.html) for the host machine, which is not yet enabled.

Instead, we configure two addition virtial NICs in VSphere for the host machine `ce-services.phy.syr.edu` which are assigned the IP addresses for the relevant services by the campus DHCP server. We then need to:

To simplify routing, we keep DCC services on a separate virtual host `ce-dcc.phy.syr.edu` until macvlan is working in AVHE.

## Configuration

 1. Configure the networking on the host machine to properly route across the three NICs. We do this by following the [RedHat instruction for multiple NICs](https://access.redhat.com/solutions/30564) connected to the same subnet to configure the host machine's networking.
 2. Run the containers that do not need external network interfaces from a Docker swarm with an attachable network.
 3. Create a bridge network for each NIC that allows containers to communicate via that NIC.
 4. Start the containers that need external interfaces from Docker compose, attach them to the bridge network for the correct NIC, and attach them to the correct swarm overlay network.
 
To allow the containers that talk over the physical NICs to route properly, the routing table must map their internal IP to the appropriate route. We therefore assign a private IP to each container and configure the routing rules appropriately. The four routes we configure are:

| Host name | Host IP | Interface | Route Number | Route Name | Private Subnet |
|-----------|---------|-----------|--------------|------------|----------------|
| ce-roster.phy.syr.edu | 128.230.146.12 | ens224 | roster | 100 | 192.168.100.0/24 |
| ce-mail.phy.syr.edu | 128.230.146.15 | ens161 | mail | 102 | 192.168.102.0/24 |
| ce-services.phy.syr.edu | 128.230.146.17 | ens160 | services | 103 | N/A |

The following addresses are assigned to the following containers with outward facing services:

| IP | Port | Container |
|----|------|-----------|
| 192.168.100.2 | 80 | Let's Encrypt Server for COmanage |
| 192.168.100.3 | 443 | COmanage Apache Server |
| 192.168.100.2 | 80 | Let's Encrypt Server for Mailman |
| 192.168.102.3 | 25 | Postfix server for Mailman |
| 192.168.102.4 | 443 | Mailman Apache Server |

Note that since the Let's Encrypt and Apache containers map to the same host IP, they cannot use the same port. This is fine, however, as Let's Encrypt runs on port 80 and we only open port 443 for Apache.

## Installation

We configure the above on the host by checking out the files in [etc/](https://github.com/cosmic-explorer/ce-it-infrastructure/edit/master/etc) of this repository on top of the host machine's filesystem.

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
```
and reboot the machine so that the changes take effect.
