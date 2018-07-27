---
layout: post
title: DIY Router With Ubuntu 14.04 LTS
subtitle: Perfect replacement for ready-made router if you do have unused computer
image: /img/router.png
share-img: /img/router.png
---
I have been using Ubuntu as my base machine for the past some years. Things have been learning from day to day since then. Recently, my thoughts have crossed the internals of routers and which turned out to be the idea of Ubuntu as a router. You would be wondering why do we need Ubuntu as a router when we have ready-made one? Assume that, we are living in a town like Mumbai where ISP provide DSL connections to the whole apartment through a switch installed on the top of it. In that case, we don't have to pay for router or something when we get connected like plugged in directly to the PC or laptop. This scenario makes to think "Linux as a router" if you love and explore the possibilities of Linux. All we have to need is two LAN card or in my case, second one is WLAN as a Wireless Access Point. Wireless Access Point provide internet as well as IP address from the configured DHCP server which I have installed in my machine. Following are the needful.

* DHCP Server
* Hostapd
* IPtable Configuration
* Switch Linux as Router
* Configure Network

### DHCP Server

> sudo apt-get install dnsmasq

> sudo vim /etc/dnsmasq.conf

```bash
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.14,12h
```

### Hostapd

> sudo apt-get install hostapd

> sudo vim /etc/default/hostapd.conf

```bash
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

> sudo nano /etc/hostapd/hostapd.conf

```bash
auth_algs=1
beacon_int=50
channel=3
country_code=US
disassoc_low_ack=1
driver=nl80211
hw_mode=g
ht_capab=[HT40+][HT40-][SHORT-GI-40][RX-STBC1]
ieee80211d=1
ieee80211n=1
interface=wlan0
require_ht=0
rsn_pairwise=CCMP
ssid=YOURSSID
wmm_enabled=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_passphrase=YOURPASSPHASE
```

### IPtables

>sudo nano /etc/rc.local

```bash
iptables -t nat -A POSTROUTING \
-o wlan1 -j MASQUERADE
iptables -A FORWARD -m conntrack \
--ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD \
-i wlan0 -o wlan1 -j ACCEPT
exit 0
```

### Switch Linux as router

> sudo nano /etc/sysctl.conf

```bash
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
```

### Configure Network

> sudo nano /etc/network/interfaces

```bash
auto lo wlan0
iface lo inet loopback
#access point
iface wlan0 inet static
address 10.0.0.1
netmask 255.255.255.240
gateway 10.0.0.1
dns-nameservers 192.168.1.1
wireless-mode Master
```

> sudo nano /etc/NetworkManager/NetworkManager.conf

```bash
[keyfile]
unmanaged-devices=mac:XX:XX:XX:XX:XX:XX
```

