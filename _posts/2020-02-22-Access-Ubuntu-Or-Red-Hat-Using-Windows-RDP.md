---
layout: post
title: Access Ubuntu or Red Hat using Windows RDP
date: 2020-02-22 07:39pm
image: /images/uploads/home.jpg
share-img: /images/uploads/rdp.png
excerpt: An easy way of accessing Linux machine with Windows remote desktop
  connection application.
subtitle: Very convenient for Windows users
tags: Linux Ubuntu Windows RDP VNC
---

* toc
{:toc}

### Introduction

To get access to Linux GUI in Windows we normally use VNC. However, this would require VNC configuration on Linux machine and VNC client on Window. In this tutorial we will see how to access Linux machine using Windows RDP by simply installing one package on Linux machine. For this we need:

1. Any of one Linux Desktop Enviroment like Gnome, XFCE and KDE is installed on Linux machine.
2. Require internet access on Linux machine.

**Note:** In all below commands, you can ignore `sudo` if you are using `root` user.
{: .notice}

### Install Packages
#### Ubuntu / Debian based
```bash
sudo apt-get update
sudo apt-get install xrdp tigervnc-server -y
```
#### RHEL / CentOS
```bash
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum repolist
sudo yum install xrdp tigervnc-server -y
```

### Start And Enable Service
#### Systemd
```bash
sudo systemctl start xrdp
sudo systemctl enable xrdp
```
#### SysVinit
```bash
sudo service xrdp start
sudo service xrdp enable
```

### Check Service
#### Command
```bash
sudo netstat -tulpn
```
#### Output
```bash
tcp        0      0 0.0.0.0:3389            0.0.0.0:*               LISTEN      1508/xrdp
tcp        0      0 127.0.0.1:3350          0.0.0.0:*               LISTEN      1507/xrdp-sesman
```

### Enable Firewall
#### Ubuntu / Debian based
```bash
sudo ufw allow 3389/tcp
```
#### RHEL / CentOS
```bash
sudo firewall-cmd --permanent --zone=public --add-port=3389/tcp
sudo firewall-cmd --reload
```

### Enable SELinux
#### RHEL / CentOS
```bash
chcon --type=bin_t /usr/sbin/xrdp
chcon --type=bin_t /usr/sbin/xrdp-sesman
```

### Test Connectivity
#### Remote Desktop Connection
* Enter IP / Hostname

![RDC](/images/rdc.png)

#### XRDP
* Select module `sesman-Xvnc`
* Enter username (root/other user)
* Enter password
* Press OK

![XRDP](/images/xrdp.png)

Questions? Please do ask in comment section or find me on [twitter](https://twitter.com/kevy_vinu)
