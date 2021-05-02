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
* toc
{:toc}

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
### Registry for disconnected OpenShift
```bash
$ sudo mkdir -p /opt/registry/{auth,certs,data}
$ sudo chown -R $USER /opt/registry
$ sudo wget --quiet https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssljson_1.5.0_linux_amd64 -O /usr/local/bin/cfssljson
$ sudo wget --quiet https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl_1.5.0_linux_amd64 -O /usr/local/bin/cfssl
$ sudo chmod 755 /usr/local/bin/cfssl /usr/local/bin/cfssljson
$ cfssl version ; cfssljson --version
$ cd /opt/registry/certs
$ cat << EOF > ca-config.json
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "server": {
        "expiry": "87600h",
        "usages": [
          "signing",
          "key encipherment",
          "server auth"
        ]
      },
      "client": {
        "expiry": "87600h",
        "usages": [
          "signing",
          "key encipherment",
          "client auth"
        ]
      }
    }
  }
}
EOF
$ cat << EOF > ca-csr.json
{
  "CN": "Foo Bar",
  "hosts": [
    "foo.example.com"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "ST": "Maharashtra",
      "L": "Mumbai",
      "OU": "Foo"
    }
  ]
}
EOF
$ cat << EOF > server.json
{
  "CN": "Foo Bar",
  "hosts": [
    "foo.example.com"
  ],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "C": "IN",
      "ST": "Maharashtra",
      "L": "Mumbai",
      "OU": "Foo"
    }
  ]
}
EOF
$ cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
$ cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server server.json | cfssljson -bare server
$ htpasswd -bBc /opt/registry/auth/htpasswd openshift redhat
$ podman run -d --name mirror-registry \
  -p 5000:5000 --restart=always \
  -v /opt/registry/data:/var/lib/registry:z \
  -v /opt/registry/auth:/auth:z \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
  -v /opt/registry/certs:/certs:z \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server.pem \
  -e REGISTRY_HTTP_TLS_KEY=/certs/server-key.pem \
  docker.io/library/registry:2
$ sudo cp /opt/registry/certs/ca.pem /etc/pki/ca-trust/source/anchors
$ sudo update-ca-trust extract
$ curl -u openshift:redhat https://foo.example.com:5000/v2/_catalog
```