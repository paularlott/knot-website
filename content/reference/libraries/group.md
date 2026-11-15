---
title: knot.group
description: Group management functions for groups and their quotas.
type: API Reference
tags: [security, authentication, api, scripting]
weight: 50
---

The `knot.group` library manages groups and their quotas. It has no membership functions: a user's groups are changed in the web UI (or the REST API), and read from the `groups` key of [`knot.user.get()`](../user/) (a list of group IDs). `list()` works for any user; the other functions need the **Manage Groups** permission.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, plugin handlers, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Only when the space's environment sets `KNOT_API_PORT` or `KNOT_URL`/`KNOT_TOKEN`: there is no built-in transport, so the Python `knot.apiclient` configures itself from the agent (as the space owner) or those variables, and calls raise otherwise. See [Environment Compatibility](/reference/libraries/#environment-compatibility). |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all groups |
| `get(group_id)` | Get group by ID (UUID; use `list()` to find an ID by name) |
| `create(name, max_spaces=0, compute_units=0, storage_units=0, max_tunnels=0, file_storage_mb=0, max_buckets=0)` | Create a new group; returns its ID |
| `update(group_id, name=None, max_spaces=None, compute_units=None, storage_units=None, max_tunnels=None, file_storage_mb=None, max_buckets=None)` | Update group properties; arguments left as `None` keep their current values (including `file_storage_mb` and `max_buckets`). Returns `True` |
| `delete(group_id)` | Delete a group; returns `True` |

---

## Usage

```python
import knot.group as group

# List groups
groups = group.list()
for g in groups:
    print(f"{g['name']}")
```

---

## Group Properties

Groups contain:
- `id` - Group ID
- `name` - Group name
- `max_spaces` - Maximum spaces allowed
- `compute_units` - Compute units quota
- `storage_units` - Storage units quota
- `max_tunnels` - Maximum tunnels allowed
- `file_storage_mb` - File storage quota in MB
- `max_buckets` - Maximum file storage buckets
