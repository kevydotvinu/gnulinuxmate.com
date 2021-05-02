---
layout: post
category: posts
title: How do I use OpenShift 4.x internal registry?
date: 2021-05-02 03:48pm
share-img: /images/uploads/openshift.png
excerpt: Openshift internal registry allows you to push images to or pull them
  from the integrated registry directly using operations like podman push or
  podman pull. Skopeo is another tool that we can use to manage the images with
  OpenShift image registry. OpenShift 3.x and OpenShift 4.x are slightly
  different in terms of management. But we will cover that in this post.
tags: openshift kubernetes registry image-registry docker docker-registry skopeo
  podman oc openshift-image-registry ocr
---
### Prepare registry infomation
```bash
# Expose OpenShift v3 registry URL
$ oc expose svc docker-registry -n default

# Expose OpenShift v4 registry URL
$ oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge

# Get OpenShift v3 registry URL
$ REGISTRY=$(oc get route docker-registry -n default -o jsonpath='{.spec.host}{"\n"}')
$ REGISTRY_SVC=docker-registry.default.svc:5000

# Get OpenShift v4 registry URL
$ REGISTRY=$(oc get route default-route -n openshift-image-registry -o jsonpath='{.spec.host}{"\n"}')
$ REGISTRY_SVC=image-registry.openshift-image-registry.svc:5000

# Create a new project or use an existing one
$ oc project foo || oc new-project foo

# Get Service Account token
$ TOKEN=$(oc sa get-token builder -n foo)
```
### Push an image from laptop to OpenShift registry
```bash
# List pulled/built images
$ podman images
k8s.gcr.io/busyboxlatest      e7d168d7db45      6      years ago      2.66 MB

# Push image
$ podman push --tls-verify=false --creds="builder:$TOKEN" docker://k8s.gcr.io/busybox:latest docker://$REGISTRY/foo/busybox:latest
```
### Push an image from the internet to OpenShift registry
```bash
# Push image
$ skopeo copy --dest-tls-verify=false --dest-creds="builder:$TOKEN" docker://k8s.gcr.io/busybox:latest docker://$REGISTRY/foo/busybox:latest
```
### List registry images using `Curl`
```bash
$ curl -s -k --request 'GET' --header "Authorization: Bearer $(oc whoami -t)" https://$REGISTRY/v2/_catalog | jq
```
### Inspect an image using `Curl`
```bash
$ curl -s -k --request 'GET' --header "Authorization: Bearer ${TOKEN}" https://$REGISTRY/v2/foo/busybox/manifests/latest | jq
```
### Push an image from OpenShift registry to an external registry without exposing the Service
```bash
$ oc run --rm -i -t --image=quay.io/skopeo/stable skopeo -n foo --restart=Never -- copy --src-tls-verify=false --src-creds="builder:$TOKEN" --dest-tls-verify=false --dest-creds="<dest-token>" docker://$REGISTRY_SVC/foo/alpine docker://$DEST
```
### Write registry credential to a `~/.docker/auth.json` file
```bash
$ oc registry login --skip-check=true
$ /usr/bin/skopeo copy --authfile=~/.docker/auth.json --dest-tls-verify=false docker://k8s.gcr.io/busybox docker://$REGISTRY/foo/busybox
```
### Push image to disconnected OpenShift node
```bash
# Get image
$ skopeo login registry.redhat.io
$ skopeo copy docker://registry.redhat.io/openshift4/ose-must-gather:latest docker-archive:$(pwd)/ose-must-gather.tar
# Push image to node
$ skopeo copy docker-archive:$(pwd)/ose-must-gather.tar containers-storage:registry.redhat.io/openshift4/ose-must-gather:latest
$ crictl images | grep ose-must-gather
```
