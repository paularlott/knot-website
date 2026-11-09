---
description: Exposes server-wide information such as version, wildcard domain and tunnel domain, and builds space web port hosts.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/libraries/server/
sources:
    - resource: https://getknot.dev/reference/libraries/server/
status: stable
tags:
    - api
    - scripting
title: knot.server
type: API Reference
---
# knot.server

The `knot.server` library exposes server-wide information.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, plugin handlers, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Not available. |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `info()` | Get server-wide information |
| `host_label(user, name, port)` | The first label of a space's web port host |

---

## Usage

```python
import knot.server as server

info = server.info()
print(info['wildcard_domain'])
```

---

## Info Properties

`info()` returns:
- `version` - The knot server version string.
- `wildcard_domain` - The server's wildcard domain for space web-port URLs (e.g. `*.knot.example.com`); empty when none is configured.
- `tunnel_domain` - The server's tunnel domain as a dot-prefixed suffix (e.g. `.tunnel.example.com`) that appends straight after a tunnel name; empty when none is configured.

---

## host_label(user, name, port)

The first label of the host a space's web port is reached at, before the wildcard domain: `<user>--<name>--<port>`, lowercased. DNS allows at most 63 characters there, so when the label would be longer, the name is cut short and ends with a hyphen and an 8-character hash of the full name, which knot routes by. The web interface and events build the same host.

**Parameters:**
- `user` (string): The username of the space's owner
- `name` (string): The space's name, one of its alt names, or a pool's name
- `port` (int or string): The port number, or `"vnc"` for web VNC

**Returns:** `string` - The label, such as `alice--web-app--8080`

```python
import knot.server as server

domain = server.info()["wildcard_domain"].lstrip("*")
url = "https://" + server.host_label("alice", "web-app", 8080) + domain
```
