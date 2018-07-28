FROM ubuntu:16.04
RUN apt-get update && apt-get install -y apt-utils
RUN apt-get update && apt-get install -y gem make gcc ruby ruby-dev vim git
RUN gem install jekyll jekyll-paginate
MAINTAINER kevy
