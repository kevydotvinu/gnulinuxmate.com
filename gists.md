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


