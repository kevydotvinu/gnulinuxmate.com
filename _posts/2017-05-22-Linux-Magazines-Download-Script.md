---
layout: post
title: Linux Magazine Download Script
subtitle: Linux magazines are the good source of Linux knowledge
image: /img/magazine.png
share-img: /img/magazine.png
---
Since I have got Linux fever I have been searching for the all kind of Linux knowledge sources and found out that magazines are good sources of unheard things. As it turns out, I have made one script which quite small in lines but download all latest and previous issues of MagPi as well as Linux Voice magazines. Append below mentioned lines to `bashrc` file would run the script flawlessly.

```bash
LinuxVoice_Magazine_Downloader () {
mkdir -p ~/LinuxVoice
cd ~/LinuxVoice/
for i in {001..050} 
do wget --read-timeout=5 --tries=0 -c \
https://www.linuxvoice.com/issues/$i/Linux-Voice-Issue-$i.pdf 
done
cd
}
```

```bash
MagPi_Magazine_Downloader () {
mkdir -p ~/MagPi
cd ~/MagPi/
wget -c -r -A.pdf -np -nd -l1 -erobots=off \
https://www.raspberrypi.org/magpi-issues
cd
}
```

New issues of Linux Voice is no longer available as it merged to Linux Magazine but it worth downloading the previous issues as a Linux enthusiast.
