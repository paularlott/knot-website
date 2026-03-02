---
title: knot.role
weight: 90
---

The `knot.role` library provides role management functions.

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
    print(f"{r['name']}: {r['permissions']}")
```
