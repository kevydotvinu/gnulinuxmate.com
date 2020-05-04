---
layout: post
category: posts
title: Open source CMS for Jekyll site hosted on GitHub Pages - Netlifycms
date: 2020-05-04 09:49am
image: ""
description: A step-by-step instructions to deploy Netlifycms on GitHub Pages.
tags: Netlify GitHub Jekyll OpenShift Heroku CMS
---
#### Why do we need CMS for Jekyll?

[Jekyll](https://jekyllrb.com/) is an awesome static site generator. However, in terms of content management workflow, it is not that simple enough and we need a fully fledged CMS like [Netlifycms](https://www.netlifycms.org/).

#### What are the options in Netlifycms?

We have two options:

1. Migrate the site on Netlify.
2. Simply deploy Netlify CMS on GitHub Pages with external oauth.

First one is straight forward and you can find the instructions in [here](https://www.netlify.com/blog/2016/10/27/a-step-by-step-guide-deploying-a-static-site-or-single-page-app/). In this post we demonstrate the second option in detail. For external oauth, we can use [](https://www.heroku.com/)[Heroku](https://www.heroku.com/) or [OpenShift](https://www.openshift.com/products/online/) platform to deploy [](https://nodejs.org/)[Netlifycms oauth](https://www.netlifycms.org/docs/external-oauth-clients/) code for free (Free quota is enough for this code).

#### Why do we need GitHub Pages when we have free Netlify hosting + CMS?

We will not get fine grain control over our site. It is easy to make changes to the site itself when we are hosting on [GitHub Pages](https://pages.github.com/).