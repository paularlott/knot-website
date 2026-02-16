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

Templates contain:
- `id` - Template ID
- `name` - Template name
- `description` - Description
- `platform` - Platform (e.g., "linux/amd64")
- `active` - Whether the template is active
- `usage` - Current usage count
- `deployed` - Number of deployed spaces
