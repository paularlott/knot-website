---
title: Network Policy
description: Restrict outbound network access for MCP tool and event sink scripts running in the knot server.
type: Guide
tags: [scripting, security]
weight: 20
---

By default, MCP tool and event sink scripts (the [Server environment](../#server-environment)) can reach the network without restriction via `requests`, `scriptling.wait_for`, `scriptling.ai` and `scriptling.mcp`. To lock that down, point `server.script_net_policy` (flag `--script-net-policy`, env `KNOT_SCRIPT_NET_POLICY`) at a TOML policy file.

This is the network equivalent of [`server.script_fs_allowed_paths`](../#server-environment), which restricts filesystem access for the same scripts.

---

## Example

```toml
# /etc/knot/network-policy.toml
allow_hosts = ["api.example.com", ".internal.corp"]
https_only = true
```

## Fields

All fields are optional.

| Field                        | Meaning                                                            |
| ---------------------------- | ------------------------------------------------------------------- |
| `allow_hosts`                | Only these hosts may be contacted (exact, or `.domain.suffix` for any subdomain) |
| `deny_hosts`                 | Always blocked, even if `allow_hosts` would permit them              |
| `https_only`                 | Reject plain `http://`/`ws://` URLs                                   |
| `allow_ip_literals`          | Permit URLs that name an IP directly (off by default)                 |
| `allow_loopback`             | Permit `127.0.0.1`/`::1` (off by default)                              |
| `allow_private_ips`          | Permit private/LAN address ranges (off by default)                    |
| `allow_cidrs` / `deny_cidrs` | Explicit address ranges to allow or block                             |
| `dns_servers`                | Resolve through these DNS servers instead of the system resolver      |
| `client_timeout`             | Cap each request end-to-end, e.g. `"30s"`                              |

This is the same TOML schema as the scriptling CLI's own [`--network-policy`](https://scriptling.dev/docs/cli/network-policy/) flag.

## Behavior

- Leave `server.script_net_policy` unset to keep network access unrestricted — the default, unchanged from earlier releases.
- Knot refuses to start if the file is missing or invalid, and refuses to build the environment for any script that would run under it — never a silent fallback to an open policy.
- Edits to the file take effect on the next script run; no server restart needed.
- `knot.ai` and `knot.mcp` are unaffected — they route through the server's own managed AI provider and MCP connections rather than making their own outbound calls, so this policy doesn't apply to them.
