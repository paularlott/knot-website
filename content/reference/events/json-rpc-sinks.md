---
title: JSON-RPC Sinks
description: JSON-RPC sinks are named formatters that deliver events to running script methods via body templates.
type: Reference
tags: [api, events]
weight: 30
---

JSON-RPC sinks are **named formatters** that deliver events to running script methods. Unlike webhook or script sinks, a JSON-RPC sink has no destination of its own — it formats event data into a payload that is passed to a method on a running script session.

A script method subscribes to events by declaring `events` in its method definition. Optionally, `event_sinks` references named formatters that transform the event data before passing it to the method. When an event fires, the dispatcher finds matching subscriptions and calls the method via JSON-RPC.

---

## How It Works

1. **`events`** (required for subscription): declares which event patterns the method subscribes to.
2. **`event_sinks`** (optional formatters): references named JSON-RPC sinks defined in the UI whose body templates format the event data.
3. When an event fires, the server delivers it to matching method subscriptions on running sessions owned by the same user.

### `events`

Subscribes the method directly to event patterns. The method receives the default event payload format:

**TOML** (`methods.toml`):

```toml
[server]
type = "stdio"
command = "./bin/my-server"

[[methods]]
name = "handle_events"
local_name = "handle_events"
description = "React to space lifecycle events"
events = ["space.created", "space.started"]
```

**Scriptling** (`methods.py`):

```python
import knot.methods

server = knot.methods.Server("my-server")

server.method(
    name="handle_events",
    description="React to space lifecycle events",
    events=["space.created", "space.started"],
)

server.register()
```

Register with `knot methods register methods.toml` (or `.py`) from inside the space.

The method receives a single `params` argument with the default format:

```json
{
  "event_id":   "...",
  "event_type": "space.created",
  "event_ts":   "...",
  "data": { ... }
}
```

### `event_sinks`

Optional formatters. References named JSON-RPC sinks defined in the UI. Each sink has its own event patterns and body template. When a matching event is delivered to the method, the server checks each referenced sink's patterns in declaration order. The first matching sink's body template formats the payload. If no referenced sink matches, the default format is used.

`event_sinks` does **not** subscribe the method to events — `events` is always required for that. `event_sinks` only controls how the payload is formatted.

**TOML** (`methods.toml`):

```toml
[[methods]]
name = "handle_deploy"
local_name = "handle_deploy"
description = "Handle deployment events"
events = ["custom.deploy.*"]
event_sinks = ["deploy-formatter"]
```

**Scriptling** (`methods.py`):

```python
server.method(
    name="handle_deploy",
    description="Handle deployment events",
    events=["custom.deploy.*"],
    event_sinks=["deploy-formatter"],
)
```

In this example:
- The method subscribes to `custom.deploy.*` events (via `events`).
- When a matching event fires, the server checks the `deploy-formatter` sink's patterns.
- If `deploy-formatter` matches, its body template formats the data → passed to the method.
- If `deploy-formatter` doesn't match (e.g., the event is `custom.deploy.rollback` and the sink only matches `custom.deploy.success`), the default format is used.

---

## JSON-RPC Sink Configuration

| Field | Description |
|-------|-------------|
| **Name** | Unique identifier referenced by `event_sinks` in method definitions |
| **Description** | Human-readable description |
| **Event Patterns** | Comma-separated glob patterns this formatter applies to |
| **Body Template** | Go template rendered into the method payload. Same template engine as webhook sinks. Leave empty for default format. |
| **Active** | Toggle whether this sink participates in event delivery |

---

## Scope

Events are delivered only to sessions owned by the **same user** as the event source. Events from other users' spaces are never delivered to your methods. This filter is automatic — no configuration needed.

---

## Delivery

- Events are delivered to the method via the same JSON-RPC call path as MCP tool invocation (server → agent → script).
- Delivery is handled by the zone leader, same as webhook and script sinks.
- Same at-least-once semantics: 3 attempts with 5s / 15s backoff on failure.
- If the agent session is offline (space stopped), delivery is not attempted — the method is not reachable.

---

## Body Template

Uses the same Go template engine and variables as [Webhook Sinks](../webhook-sinks/). Available scopes: `.event`, `.space`, `.actor`, `.custom`.

Example formatter that extracts only relevant fields for a deploy notification:

```
{
  "action": "${{ .event.type }}",
  "space":  "${{ .space.name }}",
  "version": "${{ .event.data.version }}",
  "commit":  "${{ .event.data.commit }}"
}
```

---

## Example: Log Incoming Events

A complete method server that logs every event it receives:

**`methods.py`** (register the subscription):

```python
from knot.methods import Server

server = Server("scriptling", args=["--json-rpc", "./handler.py"])

server.method(
    name="log_events",
    description="Log incoming events",
    events=["space.*", "custom.*"],
)

server.register()
```

**`handler.py`** (route and handle the call):

```python
import json
import scriptling.runtime as runtime

runtime.jsonrpc.method("log_events", "handlers.log_events")
```

**`handlers.py`** (the actual handler):

```python
def log_events(params):
    print(f"Event: {params['event_type']} ({params['event_id']})")
    print(f"  data: {json.dumps(params.get('data', {}))}")
    return {}
```

Register from inside the space:

```shell
knot methods register methods.py
```
