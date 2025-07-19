---
title: "Changelog"
description: "Keep track of all changes, updates, and improvements to knot."
layout: "changelog"
draft: false
weight: 100
---

## July Updates

{{< version "v0.18.0" >}}

This release introduces significant updates, with the most notable being a complete rewrite of the cluster mode. The new leaderless architecture ensures that all servers in the cluster are equal, eliminating the need for a designated leader. This change improves both availability and performance, allowing the system to continue functioning seamlessly even if connections between nodes are interrupted.

{{< changelog-item "changed" >}}
- **Cluster Support**: The cluster mode has been rewritten to operate in a leaderless configuration, enhancing availability and performance.
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- **Variables in Templates**: Templates can now define a set of variables, which are made available when creating a space.
- **Enhanced Tunneling**: Tunnel functionality has been improved, enabling the creation of tunnels from a port within a space to a port on the local machine.
{{< /changelog-item >}}
