---
description: Supported CSI drivers knot can request volumes from on Nomad clients.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/tutorials/example-nomad-deployment/podman/csi-drivers/
sources:
    - resource: https://getknot.dev/docs/tutorials/example-nomad-deployment/podman/csi-drivers/
status: stable
tags:
    - storage
    - deployment
title: CSI Drivers
type: Overview
---
# CSI Drivers

The setup so far uses **bind-mounted volumes** on the host operating system. While this approach works well, it may not scale effectively when running multiple servers within a Nomad cluster.

To address this, **knot** supports requesting volumes from **CSI drivers**. These drivers must be installed on the Nomad clients, and **knot** will make requests to them to create and manage volumes.

Here are the supported CSI drivers:

- **[Dynamic Host Volumes](csi-drivers/dynamic-host-volume.md)**
- **[Hostpath Driver](csi-drivers/hostpath.md)**
- **[CephFS Driver](csi-drivers/cephfs.md)**
- **[Ceph RBD](csi-drivers/cephrbd.md)**
