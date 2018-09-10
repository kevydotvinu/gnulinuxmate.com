---
layout: post
title: "Linux PXE server as ProxyDHCP in Windows DHCP network"
image: /images/pxecover.jpg
tags: PXE Linux Network
---

* toc
{:toc}

### Goal
1. Install and configure PXE server on the network which already having Windows DHCP server.
2. Boot Clonezilla via PXE network boot.

### Basics of PXE, TFTP, proxy DHCP and DNSMASQ

##### Preboot eXecution Environment (PXE)

Preboot eXecution Environment (PXE, sometimes pronounced as pixie) specification describes a standardized client-server environment that boots a software assembly, retrieved from a network, on PXE-enabled clients. On the client side it requires only a PXE-capable network interface controller (NIC), and uses a small set of industry-standard network protocols such as DHCP and TFTP. The concept behind the PXE originated in the early days of protocols like BOOTP/DHCP/TFTP, and as of 2015 it forms part of the Unified Extensible Firmware Interface (UEFI) standard. In modern data centers, PXE is the most frequent choice for operating system booting, installation and deployment.

##### Trivial File Transfer Protocol (TFTP)

Trivial File Transfer Protocol (TFTP) is a simple lockstep File Transfer Protocol which allows a client to get a file from or put a file onto a remote host. One of its primary uses is in the early stages of nodes booting from a local area network. TFTP has been used for this application because it is very simple to implement.

##### ProxyDHCP

A proxy DHCP server is defined by the PXE specification as a server which sends auxiliary boot information to clients, like the boot filename, tftp server or rootpath, but leaves the task of IP leasing to the normal DHCP server. This functionality perfectly matches certain LTSP configurations where an external, unmodifiable DHCP server is present (e.g. a router).

##### DNSMASQ

Dnsmasq provides Domain Name System (DNS) forwarder, Dynamic Host Configuration Protocol (DHCP) server, router advertisement and network boot features for small computer networks, created as free software. Dnsmasq has low requirements for system resources, can run on Linux, BSDs, Android and OS X, and is included in most Linux distributions. Consequently it "is present in a lot of home routers and certain Internet of Things gadgets" and is included in Android. Dnsmasq is a lightweight, easy to configure DNS forwarder, designed to provide DNS (and optionally DHCP and TFTP) services to a small-scale network. It can serve the names of local machines which are not in the global DNS.

### Step by step Configuration

Here I am using Ubuntu 16.04 LTS as a server. However, The packages and configuration files may change if you are using any other Linux distributions.

Install the packages needed for the configuration:
```bash
sudo apt install dnsmasq pxelinux syslinux
```

Configure `dnsmasq` to act as proxyDHCP and TFTP server.
```bash
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo vim /etc/dnsmasq.conf
```

```bash
# Disable DNS Server
port=0
# Enable DHCP logging
log-dhcp
# Respond to PXE requests for the specified network;
# run as DHCP proxy
dhcp-range=172.16.1.0,proxy
# Boot filename
dhcp-boot=pxelinux.0
# Provide network boot option called "Network Boot".
pxe-service=x86PC,"Network Boot",pxelinux
enable-tftp
tftp-root=/var/lib/tftpboot
```

```bash
sudo echo "DNSMASQ_EXCEPT=lo" >> /etc/default/dnsmasq
sudo cp /usr/lib/PXELINUX/pxelinux.0 /var/lib/tftpboot/
sudo cp /usr/lib/syslinux/modules/bios{menu,ldlinux,libmenu,libutil}.c32 /var/lib/tftpboot
```

Download Clonezilla ISO file from [here](https://clonezilla.org/) and mount the image to `/mnt`

```bash
sudo mount Clonezill.iso /mnt
sudo mkdir /var/lib/tftpboot/clonezilla
sudo cp /mnt/live/{vmlinuz,initrd.img,filesystem.squashfs} /var/lib/tftpboot/clonezilla
sudo umount /mnt
sudo mkdir -p /var/lib/tftpboot/pxelinux.cfg
sudo vim /var/lib/tftpboot/pxelinux.cfg/default
```

```bash
default menu.c32
prompt 0
menu title Network Boot

label Clonezilla
	menu label Clonezilla
	kernel clonezilla/vmlinuz
	append initrd=clonezilla/initrd.img boot=live username=user union=overlay components noswap noprompt vga=788 keyboard-layouts=en lacales=en_GB.UTF-8 fetch=tftp://172.16.1.125/clonezilla/filesystem.squashfs

label exit
	menu label Boot from Hard Disk
	localboot 0
```

Now we are successfully configured the server.

### Configure Windows DHCP server to redirect to ProxyDHCP

If your TFTP server runs on the host with IP address 192.168.1.10, and if your network boot program file name is pxelinux.0, just configure your dhcp server so that its option 66 is 192.168.1.13, option 67 is pxelinux.0 and no option 60 (PXEClient).

![pxedhcp](/images/pxedhcp.png)

### Troubleshooting

If you are having any issues connecting servers, ensure to check whether the ports are opened in between the servers:

```bash
nc -vznt <ip> <tcp port>
nc -vznu <ip> <udp port>
```
