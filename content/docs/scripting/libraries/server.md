---
title: knot.server
weight: 71
---

The `knot.server` library exposes server-wide information.

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
