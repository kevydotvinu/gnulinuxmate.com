---
layout: post
title: Install GRUB On USB Drive
subtitle: Boot-up any computer with a single USB drive
share-img: /img/usb.jpg
image: /img/usb.jpg
tags: [Commandline]
---
If we are having GRUB installed on our USB drive, live CD booting will be easier from ISO files. Here assuming ``/dev/sda1`` is your device.

Open Terminal

> mkdir /mnt/USB

> mount /dev/sda1 /mnt/USB

> sudo grub-install --force --no-floppy --boot-directory=/mnt/USB/boot /dev/sda

> cd /mnt/USB/boot/grub

> wget pendrivelinux.com/downloads/multibootlinux/grub.cfg

Edit ``grub.cfg`` as per your need.

Done.
