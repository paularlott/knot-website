---
title: "Changelog"
description: "Keep track of all changes, updates, and improvements to knot."
layout: "changelog"
draft: false
weight: 100
---

## July Updates

{{< version "v0.18.0" >}}

This release sees significant changes from the previous release, the most significant is that the cluster mode has been totally rewritten, it now doesn't require an instance of knot be used as a leader but rather all servers are now equal within the cluster. This provides significantly better availability and performance, if connections between nodes is lost everything can continue working.

{{< changelog-item "changed" >}}
- Rewrite of cluster support, now works in a leaderless cluster
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- Variables, templates can define a set of variables which are made available when creating a space
- Tunnels, the tunnel functionality has been enhanced to allow creation of tunnels from a port within a space to a port on the local machine
{{< /changelog-item >}}
