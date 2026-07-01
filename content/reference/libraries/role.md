---
title: knot.role
weight: 90
---

The `knot.role` library provides role management functions.

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
| `list()` | List all roles |
| `get(role_id)` | Get role by ID or name |
| `create(name, ...)` | Create a new role |
| `update(role_id, ...)` | Update role properties |
| `delete(role_id)` | Delete a role |

---

## Usage

```python
import knot.role as role

# List roles
roles = role.list()
for r in roles:
    print(f"{r['id']}: {r['name']}")

# Get role details with permissions
r = role.get(roles[0]['id'])
print(f"{r['name']}: {r['permissions']}")
```

---

## Role Properties

`list()` returns:
- `id` - Role ID
- `name` - Role name

`get()` also includes:
- `permissions` - List of permission IDs (integers)
