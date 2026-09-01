---
description: Supported CSI drivers knot can request volumes from on Nomad clients.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/tutorials/example-nomad-deployment/docker/csi-drivers/
sources:
    - resource: https://getknot.dev/docs/tutorials/example-nomad-deployment/docker/csi-drivers/
status: stable
tags:
    - storage
    - deployment
title: CSI Drivers
type: Overview
---
# CSI Drivers

To install and set up Knot, follow the [Nomad Server Setup Guide](../../../docs/quick-start/nomad/server-setup/). This guide will walk you through the entire process, including:

- Creating the **admin user**.
- Setting up a **template**.
- Running a **space**.

---

### Storage Considerations

The setup so far uses **bind-mounted volumes** on the host operating system. While this approach works well, it may not scale effectively when running multiple servers within a Nomad cluster.

To address this, Knot supports requesting volumes from **CSI drivers**. These drivers must be installed on the Nomad clients, and Knot will make requests to them to create and manage volumes.

Here are some supported CSI drivers:

- **[Dynamic Host Volumes](csi-drivers/dynamic-host-volume.md)**
- **[Hostpath Driver](csi-drivers/hostpath.md)**
- **[CephFS Driver](csi-drivers/cephfs.md)**
- **[Ceph RBD](csi-drivers/cephrbd.md)**
