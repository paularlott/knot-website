---
description: Configure a Knot Pro license key on the server.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/configuration/licensing/
sources:
    - resource: https://getknot.dev/docs/configuration/licensing/
status: stable
tags:
    - configuration
title: Licensing
type: Overview
---
# Licensing

Knot Pro  features are unlocked by a license key configured on the server. Without a license the server runs as the open-source edition.

```toml {filename=knot.toml}
[server.license]
key = "<license-key>"
name = "<licensed organisation or individual>"
```

- **`key`**: The license key that unlocks licensed features.
- **`name`**: The licensed individual or organisation name bound to the license key.

The same values can be provided through environment variables — `KNOT_LICENSE` and `KNOT_LICENSE_NAME` — for container-based deployments where the config file is generated from the environment.
