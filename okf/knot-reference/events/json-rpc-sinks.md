---
description: JSON-RPC sinks are named formatters that deliver events to running script methods via body templates.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/events/json-rpc-sinks/
sources:
    - resource: https://getknot.dev/reference/events/json-rpc-sinks/
status: stable
tags:
    - api
    - events
title: JSON-RPC Sinks
type: Reference
---
# JSON-RPC Sinks

JSON-RPC sinks are **named formatters** that deliver events to running script methods. Unlike webhook or script sinks, a JSON-RPC sink has no destination of its own — it formats event data into a payload that is passed to a method on a running script session.

A script method subscribes to events by declaring `events` in its method definition. Optionally, `event_sinks` references named formatters that transform the event data before passing it to the method. When an event fires, the dispatcher finds matching subscriptions and calls the method via JSON-RPC.

---

## How It Works

1. **`events`** (required for subscription): declares which event patterns the method subscribes to.
2. **`event_sinks`** (optional formatters): references named JSON-RPC sinks defined in the UI whose body templates format the event data.
3. When an event fires, the server delivers it to matching method subscriptions on running sessions owned by the same user, and custom events also to other users' shared methods the sender may call (see [Scope](#scope)).

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

A method receives every matching event owned by the **same user** as the space it runs in.

A shared method (`scope = "shared"`, or one that lists `groups`) also receives **custom** events (`custom.*`) from other users, when the sender could call the method directly:

- the sender has the **Use Space Methods Shared by Others** permission, and
- if the method lists `groups`, the sender is in at least one of them.

The sender is the user who raised the event: the API caller, or the space's owner for an event raised inside a space, whose processes act as the owner. Someone a space is shared with who raises an event for it through the API reaches other users' methods on their own permission and groups, not the owner's.

System events (`space.*`) only ever reach their owner's methods, and `private` methods only ever receive their owner's events.

When a method receives another user's event, the payload carries the event (`.event`, including its `data`) and `.actor`, but not the source space's details: `.space.name` is empty, and `.space.urls` and `.custom` are empty maps.

The formatter named in `event_sinks` is always looked up among the **method owner's** JSON-RPC sinks (or global ones), whoever raised the event.

---

## Delivery

- Events are delivered to the method via the same JSON-RPC call path as MCP tool invocation (server → agent → script).
- Delivery is handled by the zone leader, same as webhook and script sinks.
- Same at-least-once semantics: 3 attempts with 5s / 15s backoff on failure.
- If the agent session is offline (space stopped), delivery is not attempted — the method is not reachable.

---

## Body Template

Uses the same Go template engine and variables as [Webhook Sinks](webhook-sinks.md). Available scopes: `.event`, `.space`, `.actor`, `.custom`.

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

## Example: Redeploy QA Spaces After CI

CI deploys a build, then every running QA space pulls it, whoever owns the space.

In each QA space, typically from its template, register a method subscribed to the CI event and shared with a `CI` group (listing `groups` makes it shared):

```toml
[server]
type = "stdio"
command = "./bin/qa-agent"

[[methods]]
name = "qa.redeploy"
local_name = "redeploy"
description = "Pull and restart the app after CI deploys"
groups = ["CI"]
events = ["custom.ci.deployed"]
```

Create a CI user in the `CI` group with the **Use Spaces** and **Use Space Methods Shared by Others** permissions, give it an API token without scopes, and raise the event at the end of the pipeline:

```bash
curl -X POST https://knot.example.com/api/events/emit \
  -H "Authorization: Bearer $KNOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type": "ci.deployed", "payload": {"version": "'"$GIT_SHA"'"}}'
```

Every running QA space's `redeploy` method is called with the version in `params.data.version`. Keep the handler idempotent: delivery is at least once, so compare the version with what is already running. A stopped space misses the event, so have the app check for the latest build when it starts too.

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
