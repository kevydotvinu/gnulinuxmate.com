---
layout: post
redirect_from: /2018-01-02-Iptables-A-Simple-Use-Case/
date: 2018-01-02 08:28pm
share-img: /img/iptables.png
subtitle: A very little knowledge of iptables can replace your expensive home router
title: Iptables - A simple use case
image: /images/iptables.jpg
description: An introduction to iptables configurations.
tags: network linux iptables firewall
---

* toc
{:toc}

### Introduction
Iptables is a user-space utility program that allows a system administrator to configure the tables provided by the Linux kernel firewall (implemented as different Netfilter modules) and the chains and rules it stores.

> "Iptables is a command line utility for configuring Linux kernel firewall implemented within the Netfilter project. The term iptables is also commonly used to refer to this kernel-level firewall. It can be configured directly with iptables, or by using one of the many frontends and GUIs. iptables is used for IPv4 and ip6tables is used for IPv6." says [ArchWiki](https://wiki.archlinux.org/index.php/iptables)

### Installation

Redhat based distribution

```bash
yum install iptables
```

Debian-based distribution

```bash
apt-get install iptables
```

After the successful installation, make sure the service is up and running. I use Ubuntu 16.04 LTS for explaning iptables here as Linux box. Clear all pre-loaded rule in iptables by the command `iptables -F` `iptables -F -t nat`. Enable iptables in start-up using `systemctl enable iptables`.

### Use case

I have been using iptables on a regular basis in my Linux-box specially assigned for network routing jobs which is Ubuntu 16.04 LTS server edition. NAT (Network Address Translation) is the iptables's feature which I am more impressed with.

> "Network address translation (NAT) is a method of remapping one IP address space into another by modifying network address information in IP header of packets while they are in transit across a traffic routing device." says Wikipedia.

Any Linux-box is having two NIC (Network Interface Card) can be turn into a router with following command:

     echo 1 > /proc/sys/net/ipv4/ipv4_forward

For persistent changes, open `/etc/sysctl.conf` and uncomment `net.ipv4.ip_forward=1`

Now the second NIC can talk to internet without flaws. NAT is mainly divided into DNAT (Destination NAT) and SNAT (Source NAT). In simple, SNAT and MASQUERADE are for outside traffic routing while DNAT for inside one. Let us take one example here.
 
                      eth0      ____      eth1                       .-,(  ),-.
      ____   __    192.168.1.1 |====| 125.99.121.62               .-(          )-.
     |    | |==|-------------->|    |--------->               -->(    internet    )
     |____| |  |               |    |          |              ^   '-(          ).-'
     /::::/ |__|               |____|          |    ______    |       '-.( ).-'
                                               '-->|_ooo_°|---'
     Workstation               Router
       Fedora          Ubuntu 16.04 LTS Server     ISP Modem
 
As the above diagram shows, Fedora 27 is my PC and Ubuntu 16.04 LTS Server is a headless server which acts as a router here. For inside network we have `eth0` network interface while `eth1` connects to the internet. I have removed `ufw` which is iptables front-end application comes default with Ubuntu distribution. To make some fresh rules we need to flush iptables rules first:

     sudo iptables -F
     sudo iptables -F -t nat

We have internal IP of 192.168.1.1 which will act as router IP and pre-configured as DHCP server. Assuming Workstation(enp2s1) has assigned the IP of 192.168.1.2 as the Workstation configured in `/etc/network/interfaces` to ask IP from DHCP server in Ubuntu machine:

     auto enp2s1
     iface enp2s1 inet dhcp

Ubuntu machine will now act as a gateway for Fedora machine and every query hits to the NIC `eth0`. Our next step is to configure `iptables` to MASQUERADE the traffic coming to `eth0` so that the internal host such as `192.168.1.2` can talk to internet. As I mentioned above, this is inside to outside traffic using the Ubuntu gateway so we use MASQUERADE or SNAT rules in POSTROUTING chain.

     sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

Now we are able to ping to 8.8.8.8 from Fedora machine as we are connected to internet. SNAT particularly useful for changing the source IP when it comes to internal to external traffic.  

Let us take DNAT into account. Consider we require a ssh connection to Fedora machine from outside world or internet (Assuming our ISP allows this, they do not usually though). This time rule is adding to PREROUTING chain:

     sudo iptables -t nat -A PREROUTING -j DNAT -p tcp --dport 22 --destination 125.99.121.62 --to-destination 192.168.1.2

`dport`: port of Ubuntu machine  
`destination`: IP of Ubuntu machine  
`to-destination`: IP of Fedora machine  

### Conclusion
We have gone through very little possibilities of iptables here. This knowledge is more enough to turn your unused PC or inexpensive dedicated PC such as Raspberry Pi into a full functioning home router. I have been using DIY home router for the past some years. If you could find any doubts, do not hesitate to ask me in the comment box below.
