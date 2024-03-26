---
layout: post
category: posts
title: Exploring MetalLB's communication with routers
date: 2024-03-26
share-img: /images/uploads/openshift.png
excerpt: A quick introduction to the communication between the MetalLB speaker Pod and router.
tags: openshift ocp ocp4 metallb bgp speaker bfd onp openshift-network-playground
---
* toc
{:toc}

### Introduction

MetalLB is a must-have Operator in the non-cloud OpenShift/Kubernetes environment. It fecilitates the automated assignment of an ExternalIP to a Service so that it can be accessed from the outside world. It attract external traffic using ARP and BGP protocol in the IPv4 network. In this post, we are discussing the usage of BGP protocol in detail. First of all, for the better understanding, we can divide our topic into three different parts.

- How to create a MetalLB + BGP lab environment?
- What are the flows of communication between the MetalLB and a router?
- How to trace an issue while configuring a BGP peer?

### How to create a MetalLB + BGP lab environment?

Here, we are using [OpenShift Network Playground (ONP)](https://github.com/kevydotvinu/openshift-network-playground) to create our lab environment. The lab environment architecture is shown below.

![Lab](/images/lab.png)

The ONP has multiple bridge interfaces. However, we are using the `sno0` bridge for the VyOS instance.

![Interface](/images/iface.png)

Let's create our SNO cluster.
```
onp sno4
```
Install and configure MetalLB.
```
cat << EOF | oc create -f -
apiVersion: v1
kind: Namespace
metadata:
  name: metallb-system
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: metallb-operator
  namespace: metallb-system
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: metallb-operator-sub
  namespace: metallb-system
spec:
  channel: stable
  name: metallb-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```
```
cat << EOF | oc create -f -
apiVersion: metallb.io/v1beta1
kind: MetalLB
metadata:
  name: metallb
  namespace: metallb-system
EOF
```
```
cat << EOF | oc create -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  namespace: metallb-system
  name: onp-bgp-pool
spec:
  addresses:
    - 10.0.0.10-10.0.0.20
---
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
  namespace: metallb-system
  name: onp-bgp-peer
spec:
  peerAddress: 192.168.126.2
  peerASN: 64512
  myASN: 64512
  holdTime: 5
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
  name: onp-bgp-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
    - onp-bgp-pool
  peers:
    - onp-bgp-peer
  communities:
    - 65535:65282
  aggregationLength: 32
  aggregationLengthV6: 128
  localPref: 100
EOF
```
```
cat << EOF | oc create -f -
apiVersion: v1
kind: Namespace
metadata:
  name: onp-metallb
---
apiVersion: v1
kind: Pod
metadata:
  name: echoserver
  namespace: onp-metallb
  labels:
    app: echoserver
spec:
  containers:
  - image: registry.k8s.io/echoserver:1.0
    imagePullPolicy: Always
    name: echoserver
    ports:
    - containerPort: 8080
    securityContext:
      runAsNonRoot: true
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      seccompProfile:
        type: RuntimeDefault
      capabilities:
        drop:
        - ALL
---
apiVersion: v1
kind: Service
metadata:
  name: echoserver
  namespace: onp-metallb
spec:
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
  selector:
    app: echoserver
  type: LoadBalancer
EOF
```

Next, install and configure VyOS. The NETWORK option is used for the bridge selection. Use the username and password as `vyos` when it prompts for the first configuration.
```
onp vyos NETWORK=sno0
```
Configure VyOS instance.
```
configure
set interfaces ethernet eth0 address 192.168.126.3/24
set protocols bgp 64512 parameters router-id 192.168.126.3
set protocols bgp 64512 neighbor 192.168.126.2 remote-as 64512
set protocols bgp 64512 neighbor 192.168.126.2 address-family ipv4-unicast
set service ssh
commit
save
exit
```

### What are the flows of communication between the MetalLB and a router?

The MetalLB communicates to the external router using the FRR container in speaker Pod. The speaker Pod uses the host-network of the node. By default, the connection initiates via the 179/TCP port. The FRR container has six states while connecting the peer. Those are Idle, Connect, Active, OpenSent, OpenConfirm and Established. We will see each ones in detail.

![Connection](/images/connection.png)

- Idle: This is the initial state when the BGP process starts or when a BGP neighbor relationship is administratively disabled. In the Idle state, the BGP speaker is not actively attempting to establish a BGP session with its configured neighbors.

- Connect: When a BGP speaker initiates a TCP connection to a configured BGP neighbor, it transitions to the Connect state. In this state, the BGP speaker waits for the TCP connection to be successfully established with the remote neighbor.

- Active: If a BGP speaker is unable to establish a TCP connection to a configured neighbor, it transitions to the Active state. In the Active state, the BGP speaker continuously attempts to establish a TCP connection with the remote neighbor.

- OpenSent: Once a TCP connection is successfully established, the BGP speaker transitions to the OpenSent state. In this state, the BGP speaker sends an OPEN message to its neighbor, proposing BGP parameters for the session.

- OpenConfirm: Upon receiving an OPEN message from its neighbor, the BGP speaker transitions to the OpenConfirm state. In this state, the BGP speaker waits to receive a KEEPALIVE or NOTIFICATION message from the neighbor to confirm the establishment of the BGP session.

- Established: After successfully completing the BGP session establishment process, the BGP speaker transitions to the Established state. In this state, the BGP speaker can exchange BGP UPDATE messages with its neighbor to exchange routing information and maintain network reachability.

![States](/images/states.png)

### How to trace an issue while configuring a BGP peer?

Here, we need to remember the different states that has mentioned previously. Suppose you have configured the BGP peer on both the ends and checking the states of the states, the below will help understand the status of the connection. This is something that I have observed while working with it.

- Idle:        Most probabily, it is a mismatch in the Open message parameters.
- Connect:     The packets are not going out of the speaker Pod.
- Active:      The TCP handshake between the speaker and router is pending.
- Established: The connection has been established and we are good with the configuration.

In the Idle state case, we can sniff the BGP packets and confirm the wrong parameters. Then you will probabily see a NOTIFICATION message that has the error information.

The continuous Connect state is something we need to check within the speaker Pod or node.

However, the Active state is the stage wherein the TCP phase has completed and initiating the BGP phase. The BGP phase has four messages. OPEN, UPDATE, NOTIFICATION and KEEPALIVE messages.

OPEN message:          This is the first exchange of BGP parameters. If it matches each other, the peer send back the OPEN message with its own parameters.

![Open](/images/open.png)

NOTIFICATION message:  Else of the above case, it sends the NOTIFICATION message that shows the error information.

![Notification](/images/notification.png)

UPDATE message:        This is the actual route exchange message.

![Update](/images/update.png)

KEEPALIVE message:     It sends each other to find the failover.

![Keepalive](/images/keepalive.png)

If one enables the BFD for the fast failover, the communication happens in the port 3784. The packets will be the BFD control message with the interval configured in the BFDProfile object.

![BFD](/images/bfd.png)
