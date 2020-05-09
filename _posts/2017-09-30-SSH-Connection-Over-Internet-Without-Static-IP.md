---
layout: post
title: SSH Connection Over Internet Without Static IP
subtitle: Perfect choice for IoT projects
tags: [Debian]
image: /images/uploads/home.jpg
---

**If you do have some Raspberry Pi projects, you should have probably tried ssh (Secure Shell). Most of all the Raspberry Pi projects are rely on the ssh remote connection. Wouldn't it be super beneficial if we could use the ssh connection through internet without any static IP and other router configuration headaches?**

Recently, I have tried one Raspberry Pi project which particularly related to surveillance. The core part of the project was ssh connection through internet. I made that easy with the help of [Dataplicity](https://www.dataplicity.com); Remotely access Raspberry Pi from anywhere in the world via web browser without DynDNS, VPN, Static IP or port forwarding. It is absolutely free of charges for one device per account. Installation process is very simple as signing up an account and copy the url which provides at the end. Next step is to login as root in the terminal and paste that url to start the installation. When it is completed, device can be accessible from the Dataplicity account. It also supports all the Debian based distributions. More information can be found in the Dataplicity [documentation pages](https://docs.dataplicity.com). Last but not least, Dataplicity Android app is available in the Google Play Store.
