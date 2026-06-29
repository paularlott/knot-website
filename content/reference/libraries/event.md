---
title: knot.event
weight: 135
---

The `knot.event` library provides event emission and access functions. The module is **context-sensitive** — `emit()` is available in space-side scripts, while `get_*()` and metadata functions are available in server-side sink scripts.

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
