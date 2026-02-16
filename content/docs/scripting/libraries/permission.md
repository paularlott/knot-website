---
title: knot.permission
weight: 110
---

The `knot.permission` library provides permission checking functions.

---

## Functions

| Function | Description |
|----------|-------------|
| `check(permission)` | Check if current user has a permission |
| `list()` | List all available permissions |

---

## Usage

```python
import knot.permission as perm

# Check a permission
if perm.check("MANAGE_SPACES"):
    print("User can manage spaces")

# List all permissions
permissions = perm.list()
for p in permissions:
    print(f"{p['name']}: {p['description']}")
```
