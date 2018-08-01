---
layout: post
title: Oracle Database Appliance Deployment
subtitle: A complete video demonstration
image: /images/oracle.jpg
redirect_from: 
 - /Oracle-Database-Appliance-Deployment/
 - /2018-02-15-Oracle-Database-Appliance-Deployment/
tag: [Installation, Database]
---

{:toc}


<style>
#markdown-toc::before {
    content: "Contents";
    font-weight: bold;
}
#markdown-toc ul {
    list-style: decimal;
}
#markdown-toc {
    border: 1px solid #aaa;
    padding: 1.5em;
    list-style: decimal;
    display: inline-block;
}
</style>

### Intoduction
Oracle Database Appliance or ODA is an Oracle Engineered System that is simple to deploy and optimized. Here, we have, ODA X6-2S. It is designed for customers requiring only single instance databases. The deployment shall take not more than around 35 minutes. This post includes full how-to-deploy video which is more than enough for the complete deployment knowledge.

### Preparing to deploy Oracle Database Appliance
Before starting deployment processes, we need to prepare the box accordingly. This post covers bare metal installation since virtualized platform not supported on the X6-2S. The preparation is as follows:  

**Download and install the patches**  
Patches consists of Grid infrastruction and RDBMS. After the successful download, copy the same to USB drive which should have filesystem type of FAT32 to avoid any mouting error. The ODA patch bundle number may change with release. Installation as follows:  

```bash
 unzip p23494985_xxxxxx_Linux-x86-64_1of2.zip
 unzip p23494985_xxxxxx_Linux-x86-64_2of2.zip
 cat p23494985_xxxxxx_Linux-x86-64_1of2.zippart p23494985_xxxxxx_Linux-x86-64_2of2.zippart > GI.zip
 update-image --image-files GI.zip
 
 unzip p23494992_xxxxxx_Linux-x86-64.zip
 update-image --image-files p23494992_xxxxxx_Linux-x86-64.zip
```

**ILOM configuration**  
ILOM is nothing but Integrated Light Out Manager designed by Sun provides advanced service processor hardware and software that you can use to manage and monitor Oracle Database Appliance. ILOM's dedicated hardware and software is preinstalled on the server. Configuration part includes IP assigning and default password change.  

**Network configuration**  
In ODA, network configuration is as easy as entering the command `configure-firstnet`.  

**CPU core configuration**  
It consist of configuring how many core do you want to be enabled (Only needed if you want less than default number of cpu cores to be enabled according to the licence).  

### Deploying Oracle Database Appliance  

You are now ready to deply ODA. Using the chrome or IE browser, enter the following URL:  


```bash
 https://<ipaddress or hostname>:7093/mgmt/index.html  
 Username: oda-admin  
 Password (default): welcome1  
```
The video demonstration of Oracle Database Appliance deployment gives the complete idea of deployment.  

[![watch](/images/play-button.png){:.centre-image}](https://player.vimeo.com/video/256223442)
<p><a href="https://vimeo.com/256223442">ODA_X6-2S_deployment</a> from <a href="https://vimeo.com/user81321720">linuxmate</a> on <a href="https://vimeo.com">Vimeo</a>.</p>

### Factory Resetting
> Cation: It will wipe out all your Oracle Database Appliance configuration

In case of mistake, where reployment is needed, the previous configuration can be wiped out using the command:  
`/opt/oracle/oak/onecmd/cleanup.pl`  
This will reboot the server.  
After the reboot, you can confirm that the previous configuration has been erased:  
```bash
 # odacli describe-appliance  
 Appliance is not configured
```

### Integrated with the Oracle Public Cloud
>"As with all Oracle Database Appliance offerings, there is strong integration with the Oracle Public Cloud, especially with the Oracle Database Cloud Service, the Oracle Backup Cloud Service and the Oracle Archive Cloud Service. Most importantly, the Oracle Database Appliance and the Oracle Public Cloud run the same software, use the same tools, and require the same skills, making it easy for customers to migrate from on-premises to the cloud and even back again if necessary." says [Oracle](https://www.oracle.com/engineered-systems/database-appliance/x6-2s/index.html).
