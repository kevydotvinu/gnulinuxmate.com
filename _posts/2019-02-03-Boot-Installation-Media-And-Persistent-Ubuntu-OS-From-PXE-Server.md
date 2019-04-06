---
title: Boot installation media and persistent Ubuntu OS from PXE Server
image: /images/boot.jpg
layout: post
tags: PXE Linux Network Ubuntu Windows
---

* toc
{:toc}

In this post, we will cover how to boot a Windows/Ubuntu installation media and a Ubuntu persistent OS from PXE server. If you are not familiar with PXE server, go through our [previous post](https://www.gnulinuxmate.com/2018/09/10/Linux-PXE-Server-As-Proxy DHCP-In-Windows-DHCP-Network/). For the explanation purpose - like we always do, we use two OS. Ubuntu 16.04 LTS and Windows 10.
The instructions can be divided into two parts:

1. PXE Server Configuration
2. Booting Configuration

## 1. PXE Server Configuration

In these instruction parts, PXE Server configuration can be found in our [previous post](https://www.gnulinuxmate.com/2018/09/10/Linux-PXE-Server-As-ProxyDHCP-In-Windows-DHCP-Network/). Here we are start explaining from booting configuration.

## 2. Booting Configuration

Here we use three boot entries, Ubuntu server, Windows installation DVD and Ubuntu persistent OS. Each of them have different configuration and the way of booting.

### Installation media - Ubuntu Desktop 16.04 LTS

1. NFS Server Configuration
2. Ubuntu Live CD mapping

#### NFS Server Configuration

First of all, install a package named `nfs-kernel`.

```bash
sudo apt install nfs-kernel
```

Then create a directory to put Ubuntu Live CD files as per you need. Here I am using `/ubuntu`.

`mkdir /ubuntu`

Next we inform the nfs server to share that particular directory to the world by changing the below config file. To prevent editing the files from client sides we share directory in read-only mode.

```bash
cat << EOF > /etc/exports
/ubuntu *(ro)
EOF
```

We are done with our nfs server part. It's time to restart the nfs server.

`sudo systemctl restart nfs-kernel`

#### Ubuntu Live CD mapping

Now do copy Ubuntu Live CD contents in `/ubuntu` directory.

```bash
sudo mount ubuntu-16.04-LTS-desktop.iso /mnt
cp -ar /mnt/* /ubuntu
```

So far so good. To boot a Linux-based OS through PXE server, we need kernel and initial ram disk files on tftp server directory. Do copy the same from Ubuntu Live CD `/ubuntu/casper/` directory and put it inside the tftp server directory `/var/lib/tftpboot/ubuntu` which should create first.

`cp /ubuntu/casper/vmlinuz /ubuntu/casper/initrd.lz /var/lib/tftpboot/ubuntu/`

Last step is to make a boot entry in PXE server.

#### Create boot entry

```bash
cat << EOF > sudo vim /var/lib/tftpboot/pxelinux.cfg/default
label Ubuntu Desktop 16.04 LTS
	menu passwd
	kernel ubuntu/vmlinuz
        append initrd=ubuntu/initrd.lz boot=casper netboot=nfs nfsroot=172.16.1.183:/ubuntu ip=dhcp rw
EOF
```

### Installation media - Windows 10

On Windows, PXE booting directly from ISO cannot be possible like Ubuntu. To make it work, we need WinPE (Windows Preinstallation Environment) to mount network drive and boot Windows ISO.

#### Create WinPE ISO

Install a package named `wimtools` on Ubuntu:

`sudo apt install wimtools`

To boot into command prompt, create a startup script, which will be included into the bootable image in the next step:

```bash
cat << EOF > start.cmd
cmd.exe
pause
EOF
```

#### Create WinPE image:

```bash
sudo mount Windows-10-DVD.iso /mnt
sudo mkwinpeimg --iso --windows-dir=/mnt --start-script=start.cmd winpe.iso
sudo umount /mnt
```

#### Create boot entry on PXE server to boot from winpe.iso:

Copy needed PXELINUX files to the TFTP server root directory

`rsync -aq /usr/lib/syslinux/bios/ /var/tftpboot/`

Move `winpe.iso` file to the TFTP server root directory

`mv winpe.iso /var/lib/tftpboot`

```bash
cat << EOF > sudo vim /var/lib/tftpboot/pxelinux.cfg/default
LABEL      WinPE
MENU LABEL Boot Windows PE from network
KERNEL     /memdisk
INITRD     winpe.iso
APPEND     iso raw
EOF
```

#### Prepare SAMBA server to put Windows 10 ISO files.

```bash
sudo mkdir /var/lib/tftp/Win10
sudo mount Windows-10-DVD.iso /mnt
sudo cp -ar /mnt/* /var/lib/tftp/Win10/
sudo umount /mnt
sudo apt install samba

cat << EOF >> /etc/samba/smb.conf
[Win10]
browsable = true
read only = yes
guest ok = yes
path = /var/lib/tftp/Win10
EOF

sudo useradd user
sudo smbpasswd user (put password - this will be used on command prompt - example: Pa$$w0rd)

sudo systemctl restart smbd
```

#### Booting Method

First select WinPE from PXE boot menu, it will give a command prompt and enter below one to mount Window 10 ISO on local machine drive I:\ to boot afterwards.

```bash
net use I:\ //<IP of SAMBA server>/var/lib/tftp/Win10 /user:user Pa$$w0rd
I:\setup.exe
```

Start the installation process as normal.

### Persistent OS - Ubuntu Server 16.04 LTS

Persistent OS is nothing but a complete OS which can be boot from PXE server and changes applied to the OS will be persistent after the reboot. Here, we create a new OS from scratch and mapping to PXE server. Root filesystem will be stored in NFS storage and the kernel and initial ram disk can be fetch from TFTP server directory.

#### Creating root filesystem

We now need an image for our boot server to serve up. To create one, we are using Ubuntu 16.04 as an OS and using a package a filesystem can be made on our local directory, which we will eventually copy over to the NFS server (at /nfs/trusty). The is a program called debootstrap that will create a nucleus of a root file system by pulling down packages from the official repos. 

```bash
# apt-get install debootstrap
# mkdir -p /nfs/trusty
# debootstrap trusty /nfs/trusty
```

After that, the  `/nfs/trusty` directory had a root filesystem:

```bash
# ls
bin   dev  home   lib   media  nfs  proc run   srv  tmp
boot  etc  lib64  mnt   opt  root sbin  sys  usr  var
```

Now we can use chroot to install things into that bare bones root filesystem.

```bash
# chroot /nfs/trusty
```

The rest of these steps are within the chroot.
Creat a user:

```bash
# adduser <username>
# usermod -a -G sudo <username>
```

The debootstrap tool may or may not set up the official Ubuntu repositories. Verify or update the repository lists:

```bash
# vi /etc/apt/sources.list
```

I did this manually to make sure they were right

```bash
deb http://ports.ubuntu.com/ubuntu-ports/ trusty main restricted
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-updates main restricted
deb http://ports.ubuntu.com/ubuntu-ports/ trusty universe
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-updates universe
deb http://ports.ubuntu.com/ubuntu-ports/ trusty multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-updates multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-backports main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-security main restricted
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-security universe
deb http://ports.ubuntu.com/ubuntu-ports/ trusty-security multiverse
```

Now that we have a working installation environment, let's get everything we need installed into our image. Tasksel will help us get the basic Ubuntu packages in.

```bash
# apt-get install tasksel
# apt-get install linux-generic
# tasksel
```

Now we need to edit /etc/fstab to mount our filesystems. (debootstrap leaves it blank)

```bash
proc                        /proc           proc    defaults                                        0       0
/dev/nfs                    /               nfs     defaults,ro,noatime                             1       1
none                        /tmp            tmpfs   defaults,rw,noexec,nosuid,size=512M             0       0
none                        /var/run        tmpfs   defaults,rw,noatime,noexec,nosuid               0       0
none                        /var/lock       tmpfs   defaults,rw,noatime,noexec,nosuid               0       0
none                        /var/tmp        tmpfs   defaults,rw,noexec,nosuid,size=128M             0       0
none                        /var/log        tmpfs   defaults,rw,noexec,nosuid,size=128M             0       0
none                        /run/shm        tmpfs   nodev,nosuid,noexec,size=256M                   0       0
```

Edit /etc/network/interfaces to set the networking (I set DHCP here, but you can use static)

```bash
auto lo
iface lo inet loopback

# Ethernet default interface
auto eth0
iface eth0 inet dhcp
```

There are a few more steps to make this pseudo system NFS bootable:

```bash
# vi /etc/initramfs-tools/initramfs.conf 
```

Make the following change:

```bash
MODULES=netboot
BOOT=nfs
```

Then rebuild the initrd:

```bash
# mkinitramfs -d /etc/initramfs-tools -o /boot/initrd.img-$(uname -r)
```

Exit the chroot:

```bash
exit
```

Now the we have the root filesystem, we need to get the kernel and initrd in the right place for dnsmasq.

```bash
cp /nfs/trusty/boot/initrd.img-$(uname -r) /var/lib/tftpboot/nfsboot/initrd
cp /nfs/trusty/boot/vmlinuz* /var/lib/tftpboot/nfsboot/vmlinuz
```

#### Create boot entry

Run below command to append new boot entry:

```bash
cat << EOF > sudo vim /var/lib/tftpboot/pxelinux.cfg/default
label Ubuntu-nfsboot
	menu passwd
	kernel nfsboot/vmlinuz
        append initrd=nfsboot/initrd boot=casper netboot=nfs nfsroot=<IP>:/nfs/trusty ip=dhcp rw
EOF
```

After booting, you will prompt for username and password which we set earlier.

Thank you for reading! And wait for my next post in which you can deploy this whole thing by just installing docker. Please don't forget to comment below what you think, doubts and your suggestions.
