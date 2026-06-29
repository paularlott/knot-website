---
title: Script Sinks
weight: 20
---

Script sinks run an existing scriptling script on the knot server when a matching event fires. The script accesses the event payload and metadata through the `knot.event` module.

---

## Configuration

| Field | Description |
|-------|-------------|
| **Script** | Search and select an existing script from your Scripts library. Only active scripts of type `script` are shown. |
| **Timeout** | Reuses the server's `MCPToolTimeout` config. |
| **User context** | The sink owner — `knot.space.*`, `knot.user.*` etc. act as this user. |

Scripts are authored on the existing [Scripts](/docs/scripting/) page and referenced from the sink by name. This keeps them reusable — one script can serve many sinks.

---

## `knot.event` Module

The `knot.event` module is **context-sensitive**. In sink scripts, only the server-side accessors are available (no `emit` — this prevents sink → event → sink recursion).

### Payload Accessors

Read values from the event's payload data using typed accessors. These mirror the `mcp.tool.get_*` pattern.

| Function | Description |
|----------|-------------|
| `knot.event.get_string(name, default="")` | Get a payload field as string |
| `knot.event.get_int(name, default=0)` | Get a payload field as integer |
| `knot.event.get_bool(name, default=False)` | Get a payload field as boolean |
| `knot.event.get_list(name, default=[])` | Get a payload field as list |
| `knot.event.get_dict(name, default={})` | Get a payload field as dict |

If the field is missing or the wrong type, the default value is returned. The accessors read only from the payload — emitter keys can never collide with system metadata fields.

### Metadata Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `knot.event.type()` | `str` | Event type string (e.g. `"space.started"`) |
| `knot.event.id()` | `str` | UUIDv7 event identifier |
| `knot.event.ts()` | `str` | HLC timestamp string |
| `knot.event.space()` | `dict` | Source space dict (`id`, `name`, `urls`) |
| `knot.event.space_urls()` | `dict` | Source space URLs (`web`, `vscode`, `terminal`) |
| `knot.event.actor()` | `dict` | Actor dict (`id`, `username`, `kind`) |
| `knot.event.custom()` | `dict` | Custom fields from the source space |

### `.custom` — Space Custom Fields

`knot.event.custom()` returns a dict of [custom fields](/docs/variables/custom-variables/) from the source space's template. Each key is the field name defined on the template, and the value is what the user entered at space-creation time:

```python
import knot.event

custom = knot.event.custom()
repo = custom.get("GITHUB_REPO", "")
env  = custom.get("DEPLOY_ENV", "production")
```

Fields that were defined on the template but not set on the space are absent from the dict.

---

## Example: Trigger a Deployment

```python
import knot.event

event_type = knot.event.type()
version = knot.event.get_string("version", "unknown")
commit  = knot.event.get_string("commit", "")
space   = knot.event.space()

if event_type == "custom.myapp.deployed":
    # Call an external API or perform server-side work
    print(f"Deploying {version} ({commit}) from {space['name']}")
```

---

## Example: React to Space Lifecycle

```python
import knot.event

event_type = knot.event.type()

if event_type == "space.stopped":
    # Clean up resources when a space stops
    node = knot.event.get_string("node_id", "")
    print(f"Space stopped on node {node}")

elif event_type == "space.unhealthy":
    failures = knot.event.get_int("consecutive_failures", 0)
    print(f"Space unhealthy after {failures} consecutive failures")
```

---

## System Event Payloads

For system events, the payload fields available via `get_*`. Space lifecycle events include `space_name` and `space_id` in the payload; `space.created` and `space.started` also include `space_urls`:

| Event | Payload fields |
|-------|----------------|
| `space.created` | `space_name`, `space_id`, `space_urls`, `template_id`, `startup_script_id` |
| `space.started` | `space_name`, `space_id`, `space_urls`, `node_id`, `started_at` |
| `space.stopped` | `space_name`, `space_id`, `stopped_at` |
| `space.deleted` | `space_name`, `space_id`, `deleted_at` |
| `space.healthy` | `space_name`, `space_id`, `previous`, `current`, `checked_at` |
| `space.unhealthy` | `space_name`, `space_id`, `previous`, `current`, `consecutive_failures`, `checked_at` |

---

## Idempotency

Delivery is at-least-once. On leader failover mid-execution, the same event may be delivered twice. **Sink scripts must be idempotent** — use `knot.event.id()` to deduplicate if needed:

```python
import knot.event

event_id = knot.event.id()
# Check if we've already processed this event_id...
# e.g. write to a file, set a flag, etc.
```

---

## Available Libraries

Sink scripts run on the knot server with the full `knot.*` library set (except `knot.event.emit`, which is not registered). See the [Scripting](/docs/scripting/) documentation for available libraries.
