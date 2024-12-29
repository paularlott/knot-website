---
title: Example Deployment
weight: 80
cascade:
  type: docs
---

{{< callout type="warning" >}}
  This example is the minimum required to deploy nomad and consul and not suitable for production environments.
{{< /callout >}}

The following assumes:

- A virtual machine with a clean install of Debian 12
- The VM has an IP address of `192.168.0.10`
- The domain names `knot.getknot.dev` and `*.knot.getknot.dev` are pointed to the VM
