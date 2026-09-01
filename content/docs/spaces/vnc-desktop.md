---
title: Desktop
description: Open a browser-based graphical VNC desktop for a space that exposes a VNC server.
type: Guide
tags: [spaces]
weight: 90
---

If a space exposes a web-based VNC server, such as [KasmVNC](https://github.com/kasmtech/KasmVNC), a **`Desktop`** button will be displayed on the **`Spaces`** page for the running space.

---

## Accessing the Desktop

1. Navigate to the **`Spaces`** page.
2. Locate the running space with the **`Desktop`** button.
3. Click the **`Desktop`** button to open a new browser tab displaying the graphical desktop.

The connection is proxied through the Knot server, so no VNC ports need to be exposed publicly.

---

## Enabling VNC in a Template

The Knot base images that include a desktop run KasmVNC; see the [base images catalogue](/docs/templates/base-images/) for which images ship a desktop. In the template's container specification, set the VNC HTTP port so the agent advertises the desktop:

```yaml
environment:
  - "KNOT_VNC_HTTP_PORT=5680"
```

The **Use VNC** permission (see [Roles](/docs/access-control/roles/)) controls whether a user sees the Desktop button.

{{< tip >}}
For a working example, the [Ubuntu Desktop template tutorial](/docs/tutorials/example-templates/ubuntu-desktop/) walks through a full desktop template with VNC enabled.
{{< /tip >}}
