---
title: knot.server
description: Exposes server-wide information such as version and wildcard domain.
type: API Reference
tags: [api, scripting]
weight: 71
---

The `knot.server` library exposes server-wide information.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Not available. |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `info()` | Get server-wide information |

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
