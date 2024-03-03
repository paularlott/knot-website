---
title: Templates
weight: 40
---

## Overview

Each developer environment or `Template`, is defined by a Nomad job and optional volume definition.

When a developer creates an instance of the `Template`, a space, and starts it, knot automatically creates any required volumes and launches the job within the Nomad cluster.

For additional isolation between developers the namespace can be set within the job specification, e.g. `namespace="${{ .user.username }}"`, if this is done then jobs for each developer are placed within their own namespaces.

## Creating a Template

From the menu select `Templates` then `Create Template`, the following form is displayed:

![](/docs/administration/create-template.webp)

The `Name` and `Nomad Job` fields are required, the `Nomad Job` field takes an HCL job specification, see [example environments](/docs/examples-environments/).

{{< callout type="info" >}}
  When a change is made to a template all running spaces are marked as an update available, however the spaces are not automatically restarted. Once the spaces are restarted they will receive the updated template.
{{< /callout >}}

Template variables can be used to hold registry login information e.g.

```hcl
image = "paularlott/knot-debian:12"
auth {
  username = "${{ .var.registry_user }}"
  password = "${{ .var.registry_pass }}"
}
```

{{< callout type="warning" >}}
  Variables are plain text within the Nomad template and can therefore be viewed via the Nomad web interface, and alternative solution such at Vault may be more applicable depending on the environment.
{{< /callout >}}

## Deleting a Template

If a template is in use then it can't be deleted.
