---
title: Licensing
description: Configure a Knot Pro license key on the server.
type: Overview
tags: [configuration]
weight: 80
---

Knot Pro {{< pro-badge >}} features are unlocked by a license key configured on the server. Without a license the server runs as the open-source edition.

```toml {filename=knot.toml}
[server.license]
key = "<license-key>"
name = "<licensed organisation or individual>"
```

- **`key`**: The license key that unlocks licensed features.
- **`name`**: The licensed individual or organisation name bound to the license key.

The same values can be provided as server flags or through environment variables — `--license` / `--license-name`, and `KNOT_LICENSE` / `KNOT_LICENSE_NAME` — for container-based deployments where the config file is generated from the environment.

To confirm a license is active, check the server log at startup — an invalid or missing key logs a warning and the server continues on the open-source edition — or the web UI footer, which shows the licensed name on a licensed server.

See [Pro Installation](../quick-start/pro-installation/) for obtaining a license key.
