---
title: knot.group
weight: 80
---

The `knot.group` library provides group management functions.

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all groups |
| `get(group_id)` | Get group by ID or name |
| `create(name, ...)` | Create a new group |
| `update(group_id, ...)` | Update group properties |
| `delete(group_id)` | Delete a group |

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
- `max_tunnels` - Maximum tunnels allowed (only in `get()`)
