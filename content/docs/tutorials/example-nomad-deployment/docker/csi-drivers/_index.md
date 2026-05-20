---
title: CSI Drivers
weight: 100
---

To install and set up **knot**, follow the [Nomad Server Setup Guide](../../../docs/quick-start/nomad/server-setup/). This guide will walk you through the entire process, including:

- Creating the **admin user**.
- Setting up a **template**.
- Running a **space**.

---

### Storage Considerations

The setup so far uses **bind-mounted volumes** on the host operating system. While this approach works well, it may not scale effectively when running multiple servers within a Nomad cluster.

To address this, **knot** supports requesting volumes from **CSI drivers**. These drivers must be installed on the Nomad clients, and **knot** will make requests to them to create and manage volumes.

Here are some supported CSI drivers:

- **[Dynamic Host Volumes](dynamic-host-volume/)**
- **[Hostpath Driver](hostpath/)**
- **[CephFS Driver](cephfs/)**
- **[Ceph RBD](cephrbd/)**
