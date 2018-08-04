---
layout: post
title: "How To Extend A Repository Size In OVM 3.3.X / 3.4.X"
image: /images/ovmrepo.jpg 
tags: Oracle Virtualization Server
---

> It is simple enough to extend the repository size in Oracle VM Manager, not through GUI though.

To increase the size of an existing repository kindly follow following steps:

Increase the size of the LUN on which the repository is created from storage end.

Refresh the storage tab in the Oracle VM Manager UI.

[Storage](#){: .btn .btn_success} -> [SAN Servers](#){: .btn .btn_success} -> [Perspective: Physical Disks](#){: .btn .btn_success} -> [LUN](#){: .btn .btn_success} -> [Refresh](#){: .btn .btn_success}

This should show the new size in the Oracle VM manager UI.
{: .notice}

Refresh the repository in the repository tab of the Oracle VM Manager UI.

[Repositories](#){: .btn .btn_success} -> [Perspective : Repositories](#){: .btn .btn_success} -> [Refresh](#){: .btn .btn_success}

This should show the new size of the repository in manager UI.
{: .notice}

`fdisk` should now report the new size for the devices, but if the devices are multipathed using device-mapper-multipath, then the multipath maps also need to be updated.

```bash
multipathd -k"resize map mpathN
```

Next, we need to extend the ocfs2 filesystem to fill the newly extended LUN.

Example:

If the LUN is `/dev/mapper/360060e80122eb80050402eb800000401`

Execute the following command in any of the Oracle VM Server where the extended LUNs are mounted as repositories:

```bash
tunefs.ocfs2 -S /dev/mapper/360060e80122eb80050402eb800000401
```

`tunefs.ocfs2` is used to adjust OCFS2 file system parameters on disk.

Note: The tool(tunefs.ocfs2) expects the cluster to be online as it needs to take the appropriate cluster locks to write safely to disk.This is an online activity and doesn't require any downtime.
{: .notice }

Refresh the repository in the repository tab of the Oracle VM Manager UI.

The filesystem should now also show the new size.

```bash
df -h
```

