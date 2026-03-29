---
title: knot.template
weight: 50
---

The `knot.template` library provides template management functions. Templates define the configuration for creating spaces.

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all templates |
| `get(template_id)` | Get template by ID or name |
| `create(name, ...)` | Create a new template |
| `update(template_id, ...)` | Update template properties |
| `delete(template_id)` | Delete a template |
| `get_icons()` | Get list of available icons |

---

## Usage

```python
import knot.template as template

# List all templates
templates = template.list()
for t in templates:
    print(f"{t['name']}: {t['platform']}")

# Get a template
t = template.get("ubuntu")
print(t['description'])

# Get available icons
icons = template.get_icons()
print(icons)
```

---

## Template Properties

`list()` returns summary objects containing:
- `id` - Template ID
- `name` - Template name
- `description` - Description
- `platform` - Platform (e.g., "linux/amd64")
- `active` - Whether the template is active
- `usage` - Current usage count
- `deployed` - Number of deployed spaces

`get()` returns the full template including all of the above plus:
- `job` - Job definition
- `volumes` - Volume definitions
- `is_managed` - Whether managed by the system
- `compute_units` - Compute units quota
- `storage_units` - Storage units quota
- `hash` - Template hash
- `with_terminal` - Terminal access enabled
- `with_vscode_tunnel` - VS Code tunnel enabled
- `with_code_server` - Code Server enabled
- `with_ssh` - SSH access enabled
- `with_run_command` - Run command enabled
- `schedule_enabled` - Schedule enabled
- `auto_start` - Auto-start enabled
- `max_uptime` - Maximum uptime value
- `max_uptime_unit` - Maximum uptime unit
- `icon_url` - Icon URL
- `groups` - List of group IDs
- `zones` - List of zone names
- `schedule` - List of schedule day dicts (`enabled`, `from`, `to`)
- `custom_fields` - List of custom field dicts (`name`, `description`)
