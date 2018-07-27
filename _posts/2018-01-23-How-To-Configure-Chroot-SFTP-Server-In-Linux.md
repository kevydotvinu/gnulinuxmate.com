---
layout: post
title: How to configure chroot SFTP server in Linux
subtitle: Only SFTP access, not SSH
image: /images/sftp.jpg
tag: [sftp, secure ftp, ssh ftp]
---

## Introduction
SFTP stands for Secure File Transfer Protocol. One of the perfect way to upload and download files. Normal FTP is not that secure to transfer data as it has security vulnerabilities. SFTP doesn't need any additional package when we have openssh installed in our machine. If we have SSH credentials, they can also act as SFTP but that is not secure way to share with everyone as it provides access to all filesystem files. Some configuration tweaks in the `/etc/ssh/ssh_config` file can limited this access to specific directory called chroot access which will secure enough to accessible by public. This is exactly what we are going to demonstrate here.

## How-To-Do

### 1. Create new user

First of all, create a new user called **linuxmate** to provide people credentials who need access to the files:

```bash
sudo useradd linuxmate -s /sbin/nologin
sudo passwd linuxmate
```

### 2. Add entries to `sshd_config` file

Open-up `/etc/ssh/sshd_config` (careful with the file name, the same directory contains file named `ssh_config`) file and uncomment `Subsystem sftp /usr/lib/openssh/sftp-server` line then add new line:

```bash
#Subsystem sftp /usr/lib/openssh/sftp-server  
Subsystem sftp  internal-sftp
```

Next we make provision access to a specific user which we created above:

```bash
Match User linuxmate  
ChrootDirectory /sftpusers/chroot/  
ForceCommand internal-sftp  
AllowTcpForwarding no  
X11Forwarding no
```

`Match User linuxmate` - Only provide access to linuxmate user, you can add group name with `Group` instead of `User` in the line.  
`ChrootDirectory /sftpusers/chroot/` - It will be the sftp chroot directory.  
`AllowTcpForwarding no` - It will not allow ssh jump connection. People will use the machine for SSH jump which can't be entertained as security will be compromised unless you are explicitly required.  
`X11Forwarding no` - Restrict access to GUI applications.  

Restart sshd service after successful configuration.

### SFTP client access

SFTP browser access can be achieved by adding browser extension or you are able to use FileZilla instead.  

![sftp-client.png](/images/sftp-client.png)

`address` - IP address of the server  
`username` - linuxmate  
`password` - _whatever you have entered_  
`port` - 22  

For commnad-line users:

` sftp linuxmate@172.168.1.199`

<html>
<head>
  <link rel="stylesheet" type="text/css" href="/assets/css/asciinema-player.css" />
</head>
<body>
  <asciinema-player src="/cast/sftp.cast" speed="2" theme="asciinema" poster="data:text/plain,\e[1;37mHow to \e[1;33mconnect \e[1;37mto sftp server" cols="100" rows="22"></asciinema-player>
  <script src="/assets/js/asciinema-player.js"></script>
</body>
</html>

### Conclusion

I believe this tutorial is complete enough to make your own SFTP server. If you have business rule such as number of files to share with public or private, SFTP will be a much appropriate way of choice as it is encrypted and simple to configure from scratch compare to conventional FTP server. When we start deploy something, it is normal to rise doubts even if the documentation gives enough information. In that case, please don't hesitate to ask in the comment box below.
