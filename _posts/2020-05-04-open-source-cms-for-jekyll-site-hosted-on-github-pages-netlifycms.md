---
layout: post
category: posts
title: Open source CMS for Jekyll site hosted on GitHub Pages - Netlifycms
date: 2020-05-04 09:49am
image: /images/uploads/home.png
share-img: /images/uploads/jekyll.jpg
excerpt: A perfect and easy CMS solution for Jekyll site hosted on GitHub Pages.
tags: Netlifycms GitHub Jekyll OpenShift CMS
---
* toc
{:toc}

### Why do we need CMS for Jekyll?

[Jekyll](https://jekyllrb.com/) is an awesome static site generator. However, in terms of content management workflow, it is not that simple enough and we need a fully fledged CMS like [Netlifycms](https://www.netlifycms.org/).

### What are the options in Netlifycms?

We have two options to deploy Netlifycms:

1. Migrate the site on Netlify.
2. Simply deploy Netlify CMS on GitHub Pages with your own OAuth.

First one is straight forward and you can find the instructions in [here](https://www.netlify.com/blog/2016/10/27/a-step-by-step-guide-deploying-a-static-site-or-single-page-app/). In this post we demonstrate the second option in detail. For external OAuth, we can use [](https://www.heroku.com/)[Heroku](https://www.heroku.com/) or [OpenShift](https://www.openshift.com/products/online/) platform to deploy [](https://nodejs.org/)[Netlifycms OAuth](https://www.netlifycms.org/docs/external-oauth-clients/) code for free (Free quota is enough for this code). Please watch [this](https://www.youtube.com/watch?reload=9&v=Xv2ZW-QPAFc) video for Heroku application as we prefer OpenShift in here.

### Why do we need GitHub Pages when we have free Netlify hosting + CMS?

We will not get fine-grained control over the site. It is easy to make changes to the site itself when we are hosting on [GitHub Pages](https://pages.github.com/).

### How to facilitate your own OAuth authentication?

On Netlifycms page, there are some [community-maintained projects](https://www.netlifycms.org/docs/external-oauth-clients/) for this. We prefer [this](https://github.com/vencax/netlify-cms-github-oauth-provider) Node.js code here.

#### Create OAuth authentication app in GitHub

Go and create OAuth app from GitHub account from [here](https://github.com/settings/developers) and make it ready your client ID and client secret.

#### Create Netlifycms authentication app on OpenShift

First create a free OpenShift account from [here](https://www.openshift.com/products/online/) and try below commands.

```shell
# clone github repository
git clone https://github.com/vencax/netlify-cms-github-oauth-provider
cd netlify-cms-github-oauth-provider

# create application
cat << EOF > ./.env
NODE_ENV=production
ORIGIN=www.yoursiteurl.com
EOF
oc new-app .
oc status
export OAUTH_CLIENT_ID=<GitHub client ID>
export OAUTH_CLIENT_SECRET=<GitHub client secret>
oc create secret githuboauth --from-literal=OAUTH_CLIENT_ID=${OAUTH_CLIENT_ID} --from-literal=OAUTH_CLIENT_SECRET=${OAUTH_CLIENT_SECRET}
oc set env --from=secret/githuboauth dc/netlify-cms-github-oauth-provider
oc patch svc/netlify-cms-github-oauth-provider -p '{"spec":{"ports":[{"name":"3000-tcp","port":3000,"protocol": "TCP","targetPort": 3000}]}}'
oc create route edge --service netlify-cms-github-oauth-provider
oc get route
```

#### Create changes in Jekyll site

In your Jekyll site root directory, create two files as follows:

```shell
admin
 ├ index.html
 └ config.yml
 
cat < EOF > admin/index.html
<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Content Manager</title>
</head>
<body>
  <!-- Include the script that builds the page and powers Netlify CMS -->
  <script src="https://unpkg.com/netlify-cms@^2.0.0/dist/netlify-cms.js"></script>
</body>
</html>
EOF

cat < EOF > admin/config.yml
backend:
  name: github
  repo: <your github repo> Ex: username/repo
  branch: <repo branch> Ex: master
  base_url: <url from oc get route command> Ex: https://netlify-cms-github-oauth-provider-netlifycms.apps.uk-east-3.starter.openshift-online.com

media_folder: "images/uploads"

publish_mode: editorial_workflow

collections:
  - label: "Blog"
    name: "blog"
    folder: "_posts"
    create: true
    fields:
      - {label: "Title", name: "title", widget: "string"}
      - {label: "Publish Date", name: "date", widget: "datetime"}
      - {label: "Image", name: "image", widget: "image"}
      - {label: "Body", name: "body", widget: "markdown"}
EOF
```

Please make changes on config.yml file as per your values and refer [this](https://www.netlifycms.org/docs/add-to-your-site/) for more information.

This is it! Now you can visit https://yousiteurl.com/admin/index.html to authenticate and see your Netlifycms console.
