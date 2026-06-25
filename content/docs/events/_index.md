---
title: Events
weight: 90
---

The events system lets you react to space lifecycle changes and custom events raised from inside spaces. Events are routed to **event sinks** — listeners that POST to a webhook URL, run a scriptling script, or deliver to a running JSON-RPC method.

---

## System Events

Knot automatically fires system events when spaces change lifecycle state:

| Event type | When | Payload data |
| ---------- | ---- | ------------ |
| `space.created` | Space record created | `space_name`, `space_id`, `space_urls`, `template_id`, `startup_script_id` |
| `space.started` | Space reached deployed state | `space_name`, `space_id`, `space_urls`, `node_id`, `started_at` |
| `space.stopped` | Space reached stopped state | `space_name`, `space_id`, `stopped_at` |
| `space.deleted` | Space marked as deleted | `space_name`, `space_id`, `deleted_at` |
| `space.healthy` | Health check transitioned to healthy | `space_name`, `space_id`, `previous`, `current`, `checked_at` |
| `space.unhealthy` | Health check transitioned to unhealthy | `space_name`, `space_id`, `previous`, `current`, `consecutive_failures`, `checked_at` |

---

## Custom Events

Anything running inside a space can raise custom events. Three equivalent paths:

### Agent CLI

```bash
knot event myapp.deployed '{"version": "1.0"}'
```

Or pipe payload via stdin:

```bash
echo '{"version": "1.0"}' | knot event myapp.deployed
```

### Agent HTTP API

```bash
curl -X POST http://127.0.0.1:12201/event \
  -H "Content-Type: application/json" \
  -d '{"type": "myapp.deployed", "payload": {"version": "1.0"}}'
```

### Scriptling

```python
import knot.event
knot.event.emit("myapp.deployed", {"version": "1.0"})
```

All three paths prepend `custom.` to the event type automatically. This means `knot event space.created` produces `custom.space.created`, not the system event.

---

## Event Sinks

Sinks are user-owned listeners. Each sink has:

- **Name** and description
- **Event patterns** — comma-separated glob patterns (`space.*`, `custom.myapp.*`, `*`, exact match)
- **Sink type** — webhook, script, or json-rpc
- **Owner** — user-owned (fires only for that user's spaces) or global (fires for all spaces)

See the dedicated pages for each sink type:

- [Webhook Sinks](webhook-sinks/) — POST events to an HTTP endpoint with a templated body
- [Script Sinks](script-sinks/) — Run a scriptling script server-side with event accessors
- [JSON-RPC Sinks](json-rpc-sinks/) — Named formatters that deliver events to running script methods

---

## Event Selection Patterns

| Pattern | Matches |
|---------|---------|
| `*` | Every event |
| `space.*` | All system space events |
| `custom.myapp.*` | Any `custom.myapp.*` event (greedy prefix match) |
| `space.created` | Exact match only |

Whitespace around entries is trimmed. No leading or middle wildcards in v1.

---

## Delivery Semantics

- Events are zone-local — they stay in the zone the space runs in.
- At-least-once delivery — consumers should dedup via the event UUID (`X-Knot-Event-Id` header for webhooks, `knot.event.id()` for scripts).
- Per-sink delivery is in-order, one at a time.
- Each sink has a bounded queue (100 events). When full, new matching events are dropped for that sink.
- Dropped events are logged and an audit entry is written.
- Three delivery attempts with 5s / 15s backoff on failure.

---

## Permissions

| Permission | Description |
|-----------|-------------|
| Manage Own Event Sinks | Create and manage user-owned sinks (fire for own spaces only) |
| Manage Global Event Sinks | Additionally manage global sinks (fire for all spaces) |
