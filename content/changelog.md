---
title: Changelog
description: Keep track of all changes, updates, and improvements to knot.
type: Changelog
tags: [changelog]
layout: "changelog"
draft: false
weight: 100
navSection: docs
---

## September 2026

{{< version "v0.36.1" >}}

{{< changelog-item "fixed" >}}
- **The spaces page broke for users with only the share permission**: it requested the user list without being allowed it, and the resulting error stopped the page loading anything. The share permission now grants the user list read the share dialog needs, and the page keeps working if that request fails.

- **UI improvements**: the Clients page command block is readable in dark mode, and share/transfer dropdown avatars load only when opened instead of on every page view.
{{< /changelog-item >}}

---

{{< version "v0.36.0" >}}

{{< changelog-item "added" >}}
- **Outbound network restrictions for server-side scripts**: a new `server.script_net_policy` setting points MCP tool and event sink scripts at a network policy file — the network equivalent of `server.script_fs_allowed_paths`. See [Network Policy](../docs/scripting/network-policy/).

- **MCP over stdio (`knot mcp`)**: run knot as a local MCP server — the command proxies the remote server's `/mcp` endpoint over stdio, authenticating from the stored connection (`--alias`) or `--server`/`--token`, never from the host's config. Also built into the agent binary, so inside a space `knot mcp` connects through the agent socket with no configuration. See [`knot mcp`](../reference/cli/knot/#knot-mcp).

- **MCP Apps in the AI chat**: a tool call linked to a `ui://` resource (the MCP Apps extension) now renders its app view inline in the conversation instead of staying buried in the tool-call disclosure. Remote MCP servers' tools and resources are exposed to the chat too, and the MCP servers management page badges app tools and shows their icons.

- **Skills served over the MCP skills extension**: knot's skills are now exposed the standard way on `/mcp`: `skills/list` and `skills/get`, with each `SKILL.md` readable as a `skill://` resource, scoped to the requesting user's access. The web assistant and the OpenAI-compatible endpoints list available skills in the system prompt — including skills from attached remote MCP servers — and pull the full content on demand. See [Skills](../docs/ai/skills/).

- **Exclusive pool member leases**: `knot pool acquire` checks out one healthy pool member for a caller's exclusive use — shared routing skips it while held, and the holder works with it by its space name, the same way they would ssh to it. The default is the simple allocate → use → release with no timeout; optional lease limits and extension caps cover shared pools and CI, and `release --destroy` swaps the member for a fresh one so the next acquire starts clean. See [Space Pools](../docs/spaces/pools/).

- **Scriptling: `knot.pool` leases**: `acquire(name, time=None, wait=None)`, `extend(space, time=None)`, `release(space, destroy=False)`, `leases(name)` and a `leased()` context manager; extend and release take the member's space name or id, durations accept `"5m"`-style strings or `"none"`. See [knot.pool](../reference/libraries/pool/).

- **Idle auto-stop for spaces**: a new template idle timeout stops a running space after it has had no user activity, an open terminal, SSH or web-port session (even idle), method calls, sustained CPU, and on Pro filesystem writes — for the configured time. Held pool leases are exempt. Set it next to Maximum Uptime in the template form, the API (`idle_timeout`, `idle_timeout_unit`), template export/import, and `knot.template.create`/`update`. See [Managing Templates](../docs/templates/managing/#runtime-limits).

- **Shared ports and cross-user forwarding**: template ports gain a **shared** type (alongside http, https and tcp), not published anywhere but reachable by every user in the same zone through port forwards, addressed as `user--space`. `knot space port forward client 5432 paul--shared-pg 5432`. Forward targets resolve as your own space, your own pool (round-robin across healthy members, leased members excluded), or another user's space/pool on shared ports; access is re-checked on every connection. Templates, pool membership and users are now cached in memory on each node, invalidated on every write. See [Space Forwarding](../docs/spaces/space-space-port-forwarding/).

- **Template port forward wiring** {{< pro-badge >}}: templates can carry port forwards seeded into every new space. Client spaces connect to their services (or a pool) automatically on start. Edited in the Pro template form; available through the API, export/import and `knot.template` everywhere.
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **The `/mcp` endpoint serves knot's own tools only**: remote MCP servers are no longer federated through the public endpoint, so its tool list describes knot alone and doesn't churn when a remote server is added, removed or changes. The web chat, the OpenAI-compatible endpoints and `knot.mcp` in scripts still list and call remote tools under their namespace prefix; external MCP clients that want a remote server's tools should connect to that server directly. See [Remote MCP Servers](../docs/ai/mcp-remote/).

- **The `get_skill` MCP tool is removed**: skills are no longer exposed as a tool on any surface. External MCP clients use the skills extension instead (`skills/list`, `skills/get`, `resources/read` on the `skill://` URI). The CLI, the `knot.skill` scripting library and the skills API are unchanged.
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- **`knot.mcp` works again**: the scriptling library's `list_tools()`, `call_tool()`, `tool_search()` and `execute_tool()` called API routes that were removed when chat moved to the OpenAI endpoints in February, so every call failed. The routes are back, resolving tools exactly like the web chat: knot's own tools plus remote MCP servers under their namespace prefix. See [knot.mcp](../reference/libraries/mcp/).

- **CSI volume deletes survive an in-flight operation**: Nomad rejects a concurrent delete with `Aborted — an operation with the given Volume ID already exists`; knot now retries for up to five minutes until the earlier operation clears, and if it stays wedged says so — with the remedy — instead of failing with the raw error.

- **The template form could never enable Maximum Uptime**: the unit was submitted as `disabled` for every platform, so the setting silently did nothing regardless of what was chosen.

- **Persistent forwards created on a stopped space never came up**: they stored the target as a space ID, which the proxy rejected, so the forward sat dead after the space started. Targets are now stored by name (`user--space` for other users' targets) and the proxy accepts names, qualified names and IDs.

- **Non-admins got an empty space list from the CLI**: `knot space list` and every other client that calls the spaces API without a `user_id` filter received nothing back, because the endpoint only allowed admins an unfiltered list. An omitted `user_id` now means the requester's own spaces; asking for another user's id still returns nothing without the manage-spaces permission.
{{< /changelog-item >}}

---

{{< version "v0.35.0" >}}

{{< changelog-item "added" >}}
- **KVM virtual machines**: a new template platform that runs spaces as full VMs on KVM-capable nodes — their own kernel and systemd, booted from a cloud-init image, with everything interactive (terminal, VS Code, SSH, scripts, jobs) working as with containers. Bridged or NAT networking per template, persistent stop/start, device passthrough, serial and graphical consoles in the browser, and full spec-wizard support. Nodes advertise the `kvm` runtime automatically. See [KVM Nodes](../docs/configuration/kvm/) and the [VM Specification](../docs/templates/kvm-templates/vm-spec/).
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- **Scriptling**: `knot.space` gains KVM IP support — `create()` and `update()` accept `ip_address`, new `get_ip_address()`/`set_ip_address()` helpers, and every space dict carries `ip_address`; `knot.template` responses expose the KVM network fields.
{{< /changelog-item >}}

{{< changelog-item "added" >}}
- **Tunnel domain everywhere the wildcard domain is**: new `server.tunnel_domain` spec/stack variable with editor autocomplete; the server-info API and `knot.server.info()` now return `tunnel_domain` alongside `wildcard_domain`.
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **Spaces list**: the log window action is hidden for KVM spaces — a VM has no container runtime to stream logs from.
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- **Tunnels now survive a knot server restart**: instead of giving up after a few seconds, tunnel clients (daemon-mode web tunnels especially) retry with backoff indefinitely and reform the tunnel, same URL, once the server is back.
{{< /changelog-item >}}
