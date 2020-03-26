---
layout: gists
title: Terminal Thoughts
---

* toc
{:toc}

**Note:** In all commands below, you can ignore `sudo` if you are using `root`.
{: .notice}

### Docker
#### Remove all docker containers
```bash
sudo docker rm $(docker -aq)
```
#### Upload local docker image to minikube
```bash
sudo docker save node/web:v1 | pv | (eval $(minikube docker-env) && docker load)
```

### Network
#### Change default route
```bash
sudo ip route change default via <IP> scope global dev eth0
```
#### SSH VPN from office to home
```bash
OFFICE=127.0.0.1
HOME=127.0.0.1
ssh -R 2222:OFFICE:22 ubuntu@AWS
ssh -L 2222:HOME:2222 ubuntu@AWS
ssh -D 9999 HOME -p 2222
ssh -o "ProxyCommand nc -x HOME:9999 %h %p" root@ANYOFFICESERVER
chromium-browser --incognito --proxy-server="socks://HOME:9999"
```
#### SSH X11 Minimal
```bash
sudo yum install xorg-x11-xauth xorg-x11-font-Type1

cat << EOF >> /etc/ssh/sshd_config
X11Forwarding yes
X11Localhost no
X11Offset 10
EOF

X11UseLocalhost no (Ubuntu)
```
#### Enable internet in offline server
```bash
# From desktop
sudo socat -d -d  TUN:192.168.32.2/24,up SYSTEM:"ssh root@172.16.1.157 socat -d -d - 'TUN:192.168.32.1/24,up'"
# From server
sudo ip route change default via 192.168.32.1 dev eth0 scope global
```

#### X11 Server
```bash
# Check port
nmap -p6000 localhost

# Check process arguments
pgrep X | xargs ps -lfwwwp

# Configure X - Edit `/etc/X11/xinit/xserverrc` and add/change:
exec /usr/bin/X "$@"

# Configure lightdm - Edit `/etc/lightdm/lightdm.conf` and add:
[SeatDefaults]
xserver-allow-tcp=true

# Configure gdm - Edit `/etc/gdm/custom.conf` and add:
[security]
DisallowTCP=false

# Grant X access
xhost +<client IP>

# Transfer cookie to client (Run from client)
ssh <server> xauth extract - :0 | xauth merge -

# Set display env variable to client
export DISPLAY=<server>:0

# Run X application from client
xterm
```

#### Wifi Access Point
```bash
# Packages, directories and environment variable
sudo apt install hostapd dnsmasq
mkdir -p $HOME/.local/bin $HOME/.local/etc
printenv | grep "/home/`whoami`/.local/bin" > /dev/null 2>&1 || echo "export PATH=$PATH:$HOME/.local/bin" >> $HOME/.bashrc && bash

# DNSMASQ configuration
cat << EOF > $HOME/.local/etc/dnsmasq.conf
bind-interfaces
server=8.8.8.8
dhcp-range=192.168.9.50,192.168.9.150,255.255.255.0,12h
EOF

# HOSTAPD configuration - Choose SSID and PASSWORD
cat << EOF > $HOME/.local/etc/hostapd.conf
driver=nl80211
ssid=<SSID>
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=<PASSWORD>
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

# Access point script
cat << EOF > $HOME/.local/bin/hotspot
#!/bin/bash
IFACE=$1
OPERATION=$2
case $OPERATION in
	start)
		sudo ip link set $IFACE down
		sudo ip addr flush $IFACE
		sudo ip addr add 192.168.9.1/24 dev $IFACE
		sudo ip link set $IFACE up
		sudo nmcli device set $IFACE managed no
		sudo killall dnsmasq > /dev/null 2>&1
		sleep 3s
		sudo dnsmasq -i $IFACE -I lo -C $HOME/.local/etc/dnsmasq.conf
		sudo killall hostapd > /dev/null 2>&1
		sleep 3s
		sudo hostapd -i $IFACE -B $HOME/.local/etc/hostapd.conf
		sudo iptables -t nat -D POSTROUTING -j MASQUERADE > /dev/null 2>&1
		sudo iptables -t nat -A POSTROUTING -j MASQUERADE
		echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null 2>&1
		;;
	stop)
		sudo ip addr flush $IFACE
		sudo nmcli device set $IFACE managed yes
		sudo killall dnsmasq > /dev/null 2>&1
		sudo killall hostapd > /dev/null 2>&1
		sudo iptables -t nat -D POSTROUTING -j MASQUERADE > /dev/null 2>&1
		echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null 2>&1
		;;
	status)
		ps -eo cmd | grep "\-[i] $IFACE" || \
			echo "hotspot is stopped"
		;;
	*)
		echo "USAGE: hotspot <interface name> <start|stop|status>"
		echo "EXAMPLE: hostapd wlan0 start"
		;;
esac
EOF

# Start access point
hotspot wlan0 start

# Stop access point
hotspot wlan0 stop
```

### Filesystem
#### Find IO waits
```bash
for x in `seq 1 1 10`; do ps -eo state,pid,cmd | grep "^D";
echo "----";
sleep 5;
done

cat /proc/<pid>/io
lsof -p <pid>
```
#### Find open syscall
```bash
strace -f -e open ls >/dev/null
```

#### Collection of grub.cfg for Linux distribution ISOs
```bash
set timeout=10
set default=0

menuentry 'debian-9.0.0-i386-DVD-1.iso' {
	set isofile='/ISO/debian-9.0.0-i386-DVD-1.iso'
	loopback loop (hd1,msdos1)$isofile
	linux (loop)/live/vmlinuz boot=live config fromiso=/ISO/$isofile
	initrd (loop)/live/initrd.img
}

menuentry "ubuntu-14.04-LTS-desktop-i386.iso" {
	loopback loop (hd0,msdos1)/ISO/ubuntu-14.04-LTS-desktop-i386.iso
	linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=/ISO/ubuntu-14.04-LTS-desktop-i386.iso splash --
	initrd (loop)/casper/initrd.lz
}

menuentry "Android-4.3-x86" --class android {
	set root='(hd0,msdos5)'
	linux /android-4.3-x86/kernel quiet root=/dev/ram0 androidboot.hardware=tx2500 acpi_sleep=s3_bios,s3_mode SRC=/android-4.3-x86 vga=788
	initrd /android-4.3-x86/initrd.img
}

menuentry "ubuntu-16.04.3-server-amd64.iso" {
	loopback loop (hd0,msdos1)/ISO/ubuntu-16.04-LTS-minimal-amd64.iso
	linux (loop)/install/vmlinuz iso-scan/filename=/ISO/ubuntu-16.04.3-server-amd64.iso splash --
	initrd (loop)/install/initrd.gz
}

menuentry "Ubuntu-gnome-16.04-desktop-i386.iso" {
	set isofile='/ubuntu-gnome-16.04-desktop-i386.iso'
	loopback loop (hd0,msdos7)$isofile
	linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$isofile splash quiet --
	initrd (loop)/casper/initrd.lz
}

menuentry 'archlinux-2016.05.01-dual.iso ' {
	set isofile='/kevy/ISO/archlinux-2016.05.01-dual.iso'
	loopback loop (hd0,msdos7)$isofile
	linux (loop)/arch/boot/i686/vmlinuz archisodevice=/dev/loop0 img_dev=/dev/sda7 img_loop=$isofile earlymodules=loop splash quiet
	initrd (loop)/arch/boot/i686/archiso.img
}

menuentry 'openSUSE-13.2-GNOME-Live-i686' {
	set isofile='/kevy/ISO/openSUSE-13.2-GNOME-Live-i686.iso'
	loopback loop (hd0,msdos7)$isofile
	linux (loop)/boot/i386/loader/linux isofrom_device=/dev/sda7 isofrom_system=$isofile splash quiet
	initrd (loop)/boot/i386/loader/initrd
}

menuentry "kali-linux-2016.1-i386.iso" {
	set isofile='/kevy/ISO/kali-linux-2016.1-i386.iso'
	loopback loop (hd0,msdos7)$isofile
	linux (loop)/live/vmlinuz boot=live findiso=$isofile noconfig=sudo username=root hostname=kali splash quiet
	initrd (loop)/live/initrd.img
}

menuentry "Windows" --class windows --class os {
	set root=(hd0,1)
	insmod part_msdos
	insmod fat
	insmod ntldr
	ntldr /bootmgr
}

menuentry 'ArchLinux' {
	set isofile='/boot/iso/archlinux-2017.04.01-x86_64.iso'
	loopback loop $isofile
	linux (loop)/arch/boot/x86_64/vmlinuz archisodevice=/dev/loop0 img_dev=$imgdevpath img_loop=$isofile earlymodules=loop
	initrd (loop)/arch/boot/x86_64/archiso.img
}

menuentry "Android-x86" {
	set root='(hdX,X)'
	linux /android-4.4-RC2/kernel quiet root=/dev/ram0 androidboot.hardware=android_x86 acpi_sleep=s3_bios,s3_mode SRC=/android-4.4-RC2S SDCARD=/data/sdcard.img
	initrd /android-4.4-RC2/initrd.img  
}

menuetry "Fedora-NetBoot" {
	set isofile='/boot/iso/Fedora.iso'
	loopback loop $isofile
	linux (loop)/isolinux/vmlinuz inst.stage2=hd:LABEL=Fedora-WS-dvd-x86_64-24 iso-scan/filename=$isofile quiet
	initrd (loop)/isolinux/initrd.img
}

menuentry "Fedora-LiveCD" {
	set isofile='/boot/iso/Fedora.iso'
	loopback loop $isofile
	linux (loop)/isolinux/vmlinuz root=live:CDLABEL=Fedora-WS-Live-24-1-2 iso-scan/filename=$isofile rd.live.image
	initrd (loop)/isolinux/initrd.img
}

menuentry "ParrotSec Persistence" {
	set isofile='/parrotSecv4u7x64.iso'
	loopback loop (hd1,msdos1)$isofile
	linux (loop)/live/vmlinuz boot=live findiso=$isofile hostname=parrot quiet splash components noautomount persistence
	initrd (loop)/live/initrd.img
}

menuentry "HDD Boot" {
	exit
}

menuentry "Shutdown" {
	halt
}
```

### Terminal
#### Terminal shortcuts

| Shortcut                                 | Function                         |
| :--------------------------------------: | :------------------------------: |
| <kbd>Ctrl</kbd>+<kbd>D</kbd>             | Exit                             |
| <kbd>Ctrl</kbd>+<kbd>C</kbd>             | SIGINT / Kill                    |
| <kbd>Ctrl</kbd>+<kbd>Z</kbd>             | SIGSTP / Suspend                 |
| <kbd>Ctrl</kbd>+<kbd>L</kbd>             | Clear Screen                     |
| <kbd>Ctrl</kbd>+<kbd>A</kbd>             | Jump to begining of line         |
| <kbd>Ctrl</kbd>+<kbd>E</kbd>             | Jump to end of line              |
| <kbd>Ctrl</kbd>+<kbd>U</kbd>             | Erase backward from cursor       |
| <kbd>Ctrl</kbd>+<kbd>K</kbd>             | Erase forward from cursor        |
| <kbd>Ctrl</kbd>+<kbd>W</kbd>             | Erase backward one word          |
| <kbd>Ctrl</kbd>+<kbd>Y</kbd>             | Paste what erased above          |
| <kbd>Ctrl</kbd>+<kbd>P</kbd>             | Previous command                 |
| <kbd>Ctrl</kbd>+<kbd>N</kbd>             | Next command                     |
| <kbd>Ctrl</kbd>+<kbd>R</kbd>             | History search                   |
| <kbd>Tab</kbd>                           | Autocomplete command             |
| <kbd>^</kbd>word<kbd>^</kbd>replacement  | Replace word in previous command |
| <kbd>Esc</kbd>+<kbd>.</kbd>              | Paste previous argument          |

#### Vim

| Command                                  | Function                         |
| :--------------------------------------: | :------------------------------: |
| :set paste                               | Paste with proper indentation    |
| :read !cat /etc/os-release               | Get output from command          |
| :%s/pattern/replacement/g                | Replace everything with pattern  |
| :set rnu                                 | Set relative line number         |
| :set number                              | Set line number                  |
| :set ff=dos                              | Save in dos format               |
| :set ff=unix                             | Save in unix format              |
| :w !sudo tee %                           | Save file with sudo              |
| <kbd>"</kbd>+<kbd>+</kbd>+<kbd>y</kbd>   | Copy to clipboard                |
| <kbd>"</kbd>+<kbd>+</kbd>+<kbd>p</kbd>   | Paste from clipboard             |

#### Tmux

| Command                                  | Function                         |
| :--------------------------------------: | :------------------------------: |
| :select-pane -P 'bg=red'                 | Set backgroud color red          |
| :set-window-option synchronize-panes     | Synchronize panes                |

### Miscellaneous
#### Share text/link via QR code
```bash
qrencode -o /tmp/mkqr.png "$(xsel -p)" && feh /tmp/mkqr.png
```
#### Free time learning
```bash
fetch {
while [ 0 ]; 
do wget -qO - http://www.commandlinefu.com/commands/random/plaintext | \
grep -v questions/comments | \
grep -v ScriptRock.com |  \
pv -q -L 9
sleep 1s
done
}
```
#### Update only newly added repository
```bash
update-repo() {
    for source in "$@"; do
        sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/${source}" \
        -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"    
    done
}
```
#### Download any mp3 song from YouTube
```bash
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
mpthree() {
youtube-dl -f 140 "ytsearch:$1 $2 $3 $4 $5 $6 $7 $8 $9"
}
```
