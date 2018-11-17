---
title: Launch an OpenStack instance via CLI
layout: post
tag: [ cloud, openstack, VM ]
---

* toc
{:toc}

### 1. Introduction
OpenStack instances (virtual machines that run inside OpenStack) can be launched either via OpenStack dashboard (OpenStack web-interface) or CLI (command-line interface). Before launching an instance via CLI, we need to check wheather below parameters are present without which we cannot make one.

| Parameters |
|:-----------|
| Source - Image of VM (virtual machine) |
| Flavor - Configuration of VM |
| Network - Network the VM should run on |
| Security Group - Network connectivity restrictions of VM |
| Keypair - SSH key to connect to the VM |

### 2. How to launch an instance

Below are the steps which will come to need if we are installed OpenStack at first time otherwise simply list the parameters and jump to launching steps 2.3.

#### 2.1 List parameters

``` bash
openstack image list
openstack flavor list
openstack netowrk list
openstack subnet list
openstack router list
openstack security group list
openstack keypair list
```

#### 2.2 Create parameters

**Note:** This is just to give the vague idea of how to create the parameters. And the explaination is in the scope of an another post.
{: .notice}

```bash
openstack image create --file images.qcow2 --disk-format qcow2 --min-disk 10
openstack flavor create --ram 2048 --vcpu 2 --disk 10 FlavorOne
openstack network create NetworkOne
openstack subnet create SubnetOne --network NetworkOne --subnet-range 192.168.1.0/24
openstack router create RouterOne
openstack router 
openstack security group create SecurityGroupOne
openstack keypair create KeypairOne
```

#### 2.3 Launch an instance

First list the parameters before start launching an instance that mentioned in the step 2.1. Here for the demonstration sake, we use some dummy parameters as follows:

| Parameters     | Value        |
| :------------: | :----------: |
| Image          | Ubuntu       |
| Flavor         | tiny         |
| Network        | Net1         |
| Security Group | SG1          |
| Keypair        | Key1         |
| User Data      | cloud-config |

**Note:** Create a file called cloud-config and its contents should be as follows:
{: .notice}
``` bash
#cloud-config
users:
  - name: user
    plain_text_passwd: 'password'
    lock-passwd: False
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
ssh_pwauth: True
```

Now we are gathered minimum number of parameters we require and lets simply hit the below command to launch an instance.

```bash
openstack server create --image Ubuntu --key-name Key1 --flavor tiny --nic net-id=Net1 --security-group SG1 --user-data cloud-config
```

<html>
<head>
  <link rel="stylesheet" type="text/css" href="/assets/css/asciinema-player.css" />
</head>
<body>
  <asciinema-player src="/cast/openstack.cast" speed="1" theme="asciinema" poster="data:text/plain,\e[1;37mHow to \e[1;33mlaunch \e[1;37man instance" cols="110" rows="22"></asciinema-player>
  <script src="/assets/js/asciinema-player.js"></script>
</body>
</html>
