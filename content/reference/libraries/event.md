---
title: knot.event
description: Event emission in space-side scripts and payload accessors in sink scripts.
type: API Reference
tags: [events, api, scripting]
weight: 135
---

The `knot.event` library provides event emission and access functions. The module is **context-sensitive** — `emit()` is available in space-side scripts, MCP tool execution, and external standalone scripts, while `get_*()` and metadata functions are available only in server-side sink scripts.

---

## Execution Environment

`knot.event` exposes different functions depending on where the script runs.

| Environment | Behaviour |
|-------------|-----------|
| Remote/space scripts, `knot run-script` | `emit()` only. Raises custom events from inside a space via the local agent API (the `custom.` prefix is added automatically). Events are associated with the originating space. |
| MCP tool execution | `emit()` only. Raises user-scoped custom events through the server's loopback API. There is no space context, so events use the nil space id and are not space-associated. |
| External (standalone scripts) | `emit()` only. With no local agent present, falls back to `knot.apiclient` and the server's `/api/events/emit` endpoint. User-scoped (nil space id). |
| Event sink scripts (server-side) | Payload and metadata accessors only (`get_string()`, `get_int()`, `get_bool()`, `get_list()`, `get_dict()`, `type()`, `id()`, `ts()`, `space()`, `space_urls()`, `actor()`, `custom()`). `emit()` is not available. |
| Health check scripts | Not available. |

---

## Space-side: emit()

Available in any script running inside a space (startup scripts, run-scripts, MCP tools).

| Function | Description |
|----------|-------------|
| `emit(type, payload={})` | Emit a custom event. The `custom.` prefix is added automatically. |

### Usage

```python
import knot.event

knot.event.emit("myapp.deployed", {"version": "1.0"})
# Becomes custom.myapp.deployed

knot.event.emit("build.complete", {
    "commit": "abc123",
    "status": "success"
})
```

---

## Server-side: sink script accessors

Available only in scripts running as event sinks (server-side).

### Payload accessors

| Function | Description |
|----------|-------------|
| `get_string(name, default="")` | Get payload parameter as string |
| `get_int(name, default=0)` | Get payload parameter as integer |
| `get_bool(name, default=False)` | Get payload parameter as boolean |
| `get_list(name, default=[])` | Get payload parameter as list |
| `get_dict(name, default={})` | Get payload parameter as dict |

### Metadata functions

| Function | Description |
|----------|-------------|
| `type()` | Event type string |
| `id()` | Event UUIDv7 id |
| `ts()` | Event HLC timestamp string |
| `space()` | Source space dict |
| `space_urls()` | Source space URL dict |
| `actor()` | Actor dict (id, username, kind) |
| `custom()` | Custom fields dict |

### Usage

```python
import knot.event

# Access payload
version = knot.event.get_string("version", "unknown")
count = knot.event.get_int("count", 0)
tags = knot.event.get_list("tags", [])

# Access metadata
event_type = knot.event.type()
space = knot.event.space()
actor = knot.event.actor()
```
