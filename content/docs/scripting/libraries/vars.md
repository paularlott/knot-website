---
title: knot.vars
weight: 100
---

The `knot.vars` library provides template variable management functions.

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all variables |
| `get(var_id)` | Get variable by ID or name |
| `create(name, value, zones=[], local=False, protected=False, restricted=False)` | Create a new variable |
| `set_value(var_id, value)` | Set variable value |
| `update(var_id, value=None, zones=None, ...)` | Update variable properties |
| `delete(var_id)` | Delete a variable |

---

## Usage

```python
import knot.vars as vars

# List variables
variables = vars.list()
for v in variables:
    print(f"{v['name']}: local={v['local']}, protected={v['protected']}")

# Create a variable
var_id = vars.create("API_KEY", "secret-value", protected=True)

# Get a variable
api_key = vars.get("API_KEY")
print(api_key['value'])

# Set a variable value
vars.set_value("API_KEY", "new-secret-value")

# Update with more options
vars.update("API_KEY", value="new-value", zones=["zone1", "zone2"])
```

---

## Variable Properties

Variables contain:
- `id` - Variable ID
- `name` - Variable name
- `value` - Variable value (empty string if protected)
- `zones` - List of zones where variable is available
- `local` - Whether variable is local
- `protected` - Whether value is protected (not returned in get)
- `restricted` - Whether variable is restricted
- `is_managed` - Whether variable is managed by the system

---

## Protected Variables

Protected variables have their values hidden when retrieved via the API. The `value` field will be empty for protected variables unless you have elevated permissions.
