---
title: knot.vars
weight: 100
---

The `knot.vars` library provides variable management functions.

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all variables |
| `get(var_id)` | Get variable by ID or name |
| `create(name, value, ...)` | Create a new variable |
| `update(var_id, ...)` | Update variable properties |
| `delete(var_id)` | Delete a variable |

---

## Usage

```python
import knot.vars as vars

# List variables
variables = vars.list()
for v in variables:
    print(f"{v['name']}: {v['value']}")

# Get a variable
api_key = vars.get("API_KEY")
print(api_key['value'])
```
