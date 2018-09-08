---
title: Docker - A brief introduction
layout: post
subtitle: Perfect tool for multi platform users
description: How to use docker?
image: /images/docker.jpg
redirect_from: /2017-12-02-Docker-A-brief-Introduction/
tag: [application, docker, linux docker, docker commands]
---

* toc
{:toc}

#### What is Docker?  
Docker is a tool designed to make it easier to create, deploy, and run applications by using containers. Containers allow a developer to package up an application with all of the parts it needs, such as libraries and other dependencies, and ship it all out as one package. By doing so, thanks to the container, the developer can rest assured that the application will run on any other Linux machine regardless of any customized settings that machine might have that could differ from the machine used for writing and testing the code.

#### Why do I use Docker?  
The prime most reason of using docker is portability of application which I use everyday life such as Jekyll. Since I use different Linux distributions across machines from my place to office I could find docker would be the perfect solution for creating instant environment which my application needs. And it is completely different from conventional virtual machines, as you can see here.

![dockervsvm](/images/docker/dockervsvm.png)

I use virtual machines but not for specific needs like website designing and distribution related terminal testing. When you switch to Docker from conventional virtual machines, you could free up considerable amount of  machine resources as well.

#### How to install Docker?  
Docker installation is well-described in the Docker [documentation](https://docs.docker.com/engine/installation/) page for any operating system which you are using. I always recommend you to install Docker from official website instead of installing from your Linux-distribution-repository or other - a good practice of installation.

#### How to start using Docker  
Now you are installed Docker and let's start using it. Here, I'm not going to go through the Docker tutorials which you could find easily from Docker official website, instead, I give you a brief introduction of how to use apache2 inside docker.

I use Jekyll and have encountered many dependency issues. The beauty of Docker is that we can run a specific application inside a fully configured docker container and carry that container to anywhere to run the same. That is, we are able to move the whole setup and run the application out of it regardless of what operation systems we are using. Since then I started using Docker I haven't cared about the application configurations. It would give the productive environment for whatever we work with.

<b>Useful commands to remember: </b>

``` bash
 docker run -ti container-name/tag
 # example: docker run -ti ubuntu:16.04
 # create a ubuntu 16.04 image and run that container
 
 docker -exec -ti container-name/tag command
 # example: docker -exec -ti /bin/bash
 # run specific command
 
 docker container ls --all
 # list all installed docker containers
 
 docker images -a
 # list all installed docker images
 
 docker rmi image-name
 # example: docker rmi ubuntu:16.04
 # remove docker image
 
 docker container rm container-id
 # example: docker conatainer rm 0fd2ff7b757a
 # remove docker container
 
 docker commit container-id image-name
 # example docker commit ff4d9939e45c ubuntu:custom
 # create custom docker image
 
 docker inspect container-name
 # example: docker inspect ubuntu:16.04
 # shows running docker container description
 
 docker ps
 # shows docker process
 
 docker build -t image-name
 # example: docker build -t jekyll:xenial .
 # build image from Dockerfile
 
 docker pull image-name:tag
 # example docker pull base/archlinux:latest
 # pulls docker image from Docker Hub
 
 docker push images-name:tag
 # example: docker push ubuntu:custom
 # pushes docker image to Docker Hub
 
```
<b>Docker Image vs Container</b>

![dockerarch](/images/docker/dockerarch.png)

The major difference between a container and an image is the top writable layer. All writes to the container that add new or modify existing data are stored in this writable layer. When the container is deleted, the writable layer is also deleted. The underlying image remains unchanged.

Let's come back to the demonstration. First of all, we require one base OS to work with inside the docker, I prefer Ubuntu 16.04 to pull from Docker Hub.

![dockerpull](/images/docker/dockerpull.png)

Now we have our Docker image to work with. Go to the Docker container and start configure apache2 with the command `docker run -ti ubuntu:16.04 /bin/bash`.

![dockerrun](/images/docker/dockerrun.png)

![dockerapache2](/images/docker/dockerapache2.png)

![dockerservice](/images/docker/dockerservice.png)

As you can see here, I have started the apache2 service successfully. Now we have our Docker conatainer is ready to commit. Commit is the command in which Docker saves the current changes of the container that we have made in the image we pulled earlier. For this, we should open an another terminal with docker terminal aisde. After a successful commit we can exit from the docker terminal.

![dockercommit](/images/docker/dockercommit.png)

Now we are close to start using apache. To start a web server index.html is inevitable. In the next step we create index.html file and run apache2 docker we have created recently.

![dockerstart](/images/docker/dockerstart.png)

Good work! We have made it. The only thing left to do is check whether it is working properly. Docker basically makes their own network card interface in the host machine. We can check the same using the command `ip addr show dev device-name`. Here I use curl command to check whether our link works proper. You may use whatever you like such us Chrome or Mozilla browser.

![dockeroutput](/images/docker/dockeroutput.png)

Voila! We have done it. To make our task easy we can also use Dockerfile and docker-compose file.

<b>Dockerfile vs docker-compose</b>
![dockerfile](/images/docker/dockerfile.jpg)

Simple example of Dockerfile

```bash
 FROM ubuntu:16.04
 RUN apt-get update && apt-get apt-utils
 RUN apt-get update && apt-get install -y gem make gcc ruby ruby-dev vim git
 RUN gem install jekyll jekyll-paginate
 MAINTAINER kevy
```
![dockerup](/images/docker/dockerup.jpg)

Simple example of docker-compose.yml

```
 version: "2"
 services:
         jekyll:
                 image: jekyll:xenial
                 container_name: jekyll
                 ports:
                         - "4000:4000"
                 volumes:
                         - "$PWD:/home"
                 command: "jekyll serve --host=0.0.0.0 --source=/home --incremental --watch"
```

### Conclusion
I'm well aware of that this post is not a zero to hero Docker information but this would make you start thinking about how Docker become useful for you.  
Thank you for reading.
