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

Knot Pro  is licensed per user with a license key configured on the server. Without a valid license the Pro server keeps all features but runs under a built-in license limited to **2 users** — creating further users is blocked until a license is configured or users are removed.

```toml {filename=knot.toml}
[server.license]
key = "<license-key>"
name = "<licensed organisation or individual>"
```

- **`key`**: The license key that unlocks licensed features.
- **`name`**: The licensed individual or organisation name bound to the license key.

The same values can be provided as server flags or through environment variables — `--license` / `--license-name`, and `KNOT_LICENSE` / `KNOT_LICENSE_NAME` — for container-based deployments where the config file is generated from the environment.

To confirm a license is active, check the server log at startup — an invalid, missing, or expired key logs a warning and the server continues with the built-in 2-user license — or the web UI footer, which shows the licensed name on a licensed server. Clicking the footer link opens **License Details** with the license status, user limit, current user count, and expiry.

When a license expires, a **14-day grace period** keeps the licensed user limit in effect while a banner warns administrators. After the grace period ends the built-in 2-user limit applies; existing users are kept, but no new users can be created while the user count is over the limit.

See [Pro Installation](../quick-start/pro-installation.md) for obtaining a license key.
