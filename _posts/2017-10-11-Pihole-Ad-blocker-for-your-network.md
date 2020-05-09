---
title: Pihole - Adblocker for your network
layout: post
subtitle: Give it a try and make your home network ad-free and faster
image: /images/uploads/home.jpg
tag: [Command-line]
---

**Pihole briefly a ad-blocker application which can be directly deployed in Linux machines to clean the network from advertisements. A Raspberry-pi will do the job very neatly if dedicated computer is your primary concern.**

As we all know, common ad-blocker application will do the job in some extent but this one can make the difference, I can tell you that. Installation is as simple as copy-paste one-line command from the official website. After the successful installation we are provided with a assigned IP which should be put into the DNS part of the devices. DNS-level ad-block is the most highlighted features of Pi-hole as we don't have to configure anything in the access side by configuring the router to have DHCP client use the Pi-hole installed device as their DNS server.

![android_dns_setting](/images/dns.jpg)

Supported operating systems
:   Raspbian: Jessie (lite / with pixel)  
    Ubuntu: 14.04 / 16.04 / 16.10  
    Fedora: 24 / 25  
    Debian: 8.6  
    CentOS: 7.2.1511 / 7.3.1611  

We could also install Pi-hole in our personal laptop/desktop if you don't want any dedicated device for the same. 

Pi-hole provides information-rich web interface which through we could keep track of the stats and change settings. We can find it at:
http://your-ip/admin/index.php or http://pi-hole/admin

If you are having a working Linux device, definitely you should give Pi-hole a try. 

Thank you for reading.
