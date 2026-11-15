---
description: Template variable management functions including protected variables.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/libraries/vars/
sources:
    - resource: https://getknot.dev/reference/libraries/vars/
status: stable
tags:
    - variables
    - api
    - scripting
title: knot.vars
type: API Reference
---
# knot.vars

The `knot.vars` library provides template variable management functions.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, plugin handlers, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| AI scripts (`run_script`) | Available, imported as `variables` (the short name `vars` would hide the builtin). |
| Health check scripts | Only when the space's environment sets `KNOT_API_PORT` or `KNOT_URL`/`KNOT_TOKEN`: there is no built-in transport, so the Python `knot.apiclient` configures itself from the agent (as the space owner) or those variables, and calls raise otherwise. See [Environment Compatibility](../libraries.md#environment-compatibility). |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all variables |
| `get(var_id)` | Get variable by ID or name |
| `create(name, value, zones=None, local=False, protected=False, restricted=False)` | Create a new variable |
| `set_value(var_id, value=None)` | Set variable value (`None` leaves it unchanged); returns `True` |
| `update(var_id, value=None, zones=None, local=None, protected=None, restricted=None)` | Update variable properties; `None` keeps the current value — omitting `value` keeps the stored value, including a protected variable's hidden one. Returns `True` |
| `delete(var_id)` | Delete a variable; returns `True` |

The flags:
- `local` - The variable is only available on the knot server where it was created
- `protected` - The value is stored encrypted and never returned when the variable is read
- `restricted` - The variable is shared only between servers within a cluster, never with a leaf node
- `zones` - Zones where the variable can be used; a `!` prefix excludes a zone

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

# Get a variable (a protected variable's value reads back as "")
api_key = vars.get("API_KEY")
print(api_key['protected'], api_key['value'])

# Set a variable value
vars.set_value("API_KEY", "new-secret-value")

# Update with more options
vars.update("API_KEY", value="new-value", zones=["zone1", "zone2"])
```

---

## Variable Properties

`list()` returns:
- `id` - Variable ID
- `name` - Variable name
- `local` - Whether variable is local
- `protected` - Whether value is protected (not returned in get)
- `restricted` - Whether variable is restricted
- `is_managed` - Whether variable is managed by the system

`get()` also includes:
- `value` - Variable value (empty string if protected)
- `zones` - List of zones where variable is available

---

## Protected Variables

Protected variables have their values hidden when retrieved via the API: `get()` always returns `value` as an empty string for a protected variable, whatever the caller's permissions (admins included). The value is only used when templates are rendered. To keep a protected value when changing other properties, call `update()` without `value`. The REST API behaves the same way: `PUT /api/templatevars/{id}` keeps the stored value when `value` is omitted or `null`, while `""` clears it.
