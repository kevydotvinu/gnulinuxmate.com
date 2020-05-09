---
layout: post
title: Install GRUB On USB Drive
date: 2017-07-12 08:58pm
image: /images/uploads/home.jpg
share-img: /images/uploads/usb.png
excerpt: Install GRUB on USB and keep it as a tool to repair PC.
subtitle: Boot-up any computer with a single USB drive
tags: cli commandline grub livecd
---
If we are having GRUB installed on our USB drive, live CD booting will be easier from ISO files. Here assuming ``/dev/sda1`` is your device.

Open Terminal

```bash
mkdir /mnt/USB
mount /dev/sda1 /mnt/USB
sudo grub-install --force --no-floppy --boot-directory=/mnt/USB/boot /dev/sda
cd /mnt/USB/boot/grub
wget pendrivelinux.com/downloads/multibootlinux/grub.cfg
```

Edit `grub.cfg` as per your need.
Done.
