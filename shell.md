---
layout: post
title: Command-line Thoughts
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
