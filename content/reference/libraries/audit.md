---
title: knot.audit
weight: 130
---

The `knot.audit` library provides audit log search and filtering functions. {{< pro-badge >}}

---

## Functions

| Function | Description |
|----------|-------------|
| `list(...)` | List audit log entries with optional filtering |
| `search(q, ...)` | Search audit logs with a text query |

---

## Usage

```python
import knot.audit as audit

# List recent audit logs
logs = audit.list()
print(f"Total: {logs['count']}")
for entry in logs['items']:
    print(f"{entry['when']} {entry['event']} by {entry['actor']}")

# Search audit logs
logs = audit.search("Login")

# Filter by actor
logs = audit.list(actor="admin@example.com")

# Filter by event type
logs = audit.list(event="Space Create")

# Filter by actor type
logs = audit.list(actor_type="System")

# Filter by date range (RFC3339)
logs = audit.list(from_time="2025-01-01T00:00:00Z", to_time="2025-01-31T23:59:59Z")

# Combine filters
logs = audit.search("template", actor_type="User", event="Template Update")

# Pagination
logs = audit.list(start=20, max_items=10)
```

---

## Function Reference

### list

```python
list(start=0, max_items=10, q="", actor="", actor_type="", event="", from_time="", to_time="")
```

List audit log entries with optional filtering.

**Parameters:**
- `start` - Offset to start at (default: 0)
- `max_items` - Maximum number of items to return (default: 10)
- `q` - Full-text search across actor, event, and details
- `actor` - Filter by actor name (exact match)
- `actor_type` - Filter by actor type: `User`, `System`, or `MCP`
- `event` - Filter by event type (exact match)
- `from_time` - Start of date range (RFC3339 string)
- `to_time` - End of date range (RFC3339 string)

**Returns:** A dict with `count` (int) and `items` (list of entry dicts).

### search

```python
search(q, start=0, max_items=10, actor="", actor_type="", event="", from_time="", to_time="")
```

Search audit logs with a text query. Convenience wrapper around `list()` with `q` as the first positional argument.

---

## Entry Properties

Each audit log entry contains:
- `id` - Audit log entry ID
- `zone` - Server zone name
- `actor` - Who performed the action
- `actor_type` - Type of actor (`User`, `System`, `MCP`)
- `event` - Event type (e.g. `Space Create`, `Login Success`)
- `when` - Timestamp of the event
- `details` - Additional details
- `properties` - Dict of additional properties (may include `source_ip`, `user_agent`)

---

## Event Types

| Event | Description |
|-------|-------------|
| `System Start` | Server started |
| `Login Success` | Successful authentication |
| `Login Failed` | Failed authentication attempt |
| `User Create` / `Update` / `Delete` | User management |
| `Space Create` / `Update` / `Delete` | Space lifecycle |
| `Space Transfer` / `Space Shared` / `Space Stop Share` | Space sharing |
| `Template Create` / `Update` / `Delete` | Template management |
| `Group Create` / `Update` / `Delete` | Group management |
| `Role Create` / `Update` / `Delete` | Role management |
| `Variable Create` / `Update` / `Delete` | Variable management |
| `Volume Create` / `Update` / `Delete` | Volume management |
| `Script Create` / `Update` / `Delete` / `Execute` | Script management |
| `Skill Create` / `Update` / `Delete` | Skill management |
