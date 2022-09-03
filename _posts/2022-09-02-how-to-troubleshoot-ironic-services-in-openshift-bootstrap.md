---
layout: post
category: posts
title: How to troubleshoot ironic services in OpenShift bootstrap node?
date: 2022-09-02 11:00pm
share-img: /images/uploads/openshift.png
excerpt: A quick introduction to how to troubleshoot an ironic service in an OpenShift bootstrap node.
tags: openshift ocp ocp4 ironic bootstrap metal3 ocp-node ocp-ipi-baremetal ipi-baremetal baremetal-operator ocp-baremetal
---
* toc
{:toc}

### Introduction

The Ironic service will be running as a container service in OpenShift bootstrap node along with the Bootkube service which is responsible for forming a temporary control plane or cluster node. Since the systemd manages the both, we can trace the logs using the `journalctl` command.

### Services we need to be checked

The systemd service name will be `ironic` so we can interact with it using the commands:
```bash
core@bootstrap $ sudo podman ps
core@bootstrap $ sudo systemctl status ironic
core@bootstrap $ sudo journalctl -f -u ironic
```

### Tools to be used

We use `baremetal` command to interact with Ironic API. This will give us the freedom to fire instruction to Ironic API regardless of what the `ironic` service intended to do for the cluster installation. Suppose one of the bare metal node has failed to turn the power ON at the time of deployment, the `baremetal` command can power it ON or inspect it again. As we do not have `baremetal` binary in the OpenShift bootstrap node, we can choose the container way.

First, create the `clouds.yaml` credential file. Once we initiate the cluster installation with `openshift-baremetal-install` command, it will generate some terraform files in the `/tmp` directory. We can parse the data from it using the `jq` tool which will be pre-installed in the bootstrap node.

```bash
core@bootstrap $ jq -jr '"clouds:","\n","  metal3:","\n","    auth_type: http_basic","\n","    username: ",.ironic_username,"\n","    password: ",.ironic_password,"\n","    baremetal_endpoint_override: ",.ironic_uri,"\n","    baremetal_introspection_endpoint_override: ",.inspector_uri,"\n"' /tmp/openshift-install-bootstrap-*/terraform.platform.auto.tfvars.json
```
Run the `ironic-client` inside a container. The below command will land upon a shell prompt where we can start using the `baremetal` commands. For example, `baremetal node list`.

```bash
core@bootstrap $ sudo podman run -ti --rm --net host --entrypoint /bin/bash -v /var/opt/metal3/auth/clouds.yaml:/clouds.yaml -e OS_CLOUD=metal3 quay.io/metal3-io/ironic-client
```

### Troubleshooting steps

Here are the usual commands we can fire from the `ironic-client`.

```bash
root@ironic-client-container $ baremetal node list
root@ironic-client-container $ baremetal node inspect <UUID>
root@ironic-client-container $ baremetal node deploy <UUID>
```

### Final thoughts

This will make our life easier to investigate the connectivity issues between our Ironic services and bare metal nodes.