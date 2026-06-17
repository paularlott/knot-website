---
title: Using Stacks
weight: 20
---

Once you have a stack template, you can create stacks from it. This page covers creating, listing, starting, stopping, restarting, and deleting stacks.

---

## Creating a Stack

Use the `knot stack create` command to create spaces from a template:

```bash
knot stack create <template> <prefix> [name]
```

- **`template`** — the name of the stack template
- **`prefix`** — prefix for space names (spaces are named `prefix-name`)
- **`name`** — stack name used to group spaces (optional, defaults to prefix)

```bash
# Create from the "lamp-stack" template with prefix "myproject"
knot stack create lamp-stack myproject

# Create with a different stack name
knot stack create lamp-stack myproject production
```

This creates spaces named `myproject-db`, `myproject-web`, and `myproject-cache` (one per space in the template, named `prefix-name`). Each space is created with:

- The template specified in the stack template
- The stack field set to the stack name (`myproject` by default, or the `name` argument)
- Dependencies resolved to actual space IDs
- Port forwards configured between spaces
- Custom fields applied

Spaces are created in a stopped state.

---

## Listing Stacks

List all stacks for the current user:

```bash
knot stack list
```

This groups spaces by their stack name and shows the status and health of each space:

```
Stack          Spaces                       Health
myproject      myproject-db (Stopped)       -
               myproject-web (Stopped)      -
               myproject-cache (Stopped)    -
```

For running spaces, health is shown as `Healthy` or `Unhealthy`. Spaces that are stopped, starting, stopping, or deleting show `-`.

---

## Starting a Stack

Start all spaces in a stack. Spaces are started in dependency order — a space waits for all its dependencies to be running before starting.

```bash
knot stack start myproject
```

---

## Stopping a Stack

Stop all spaces in a stack. Spaces are stopped in reverse dependency order — dependent spaces are stopped first.

```bash
knot stack stop myproject
```

---

## Restarting a Stack

Restart all spaces in a stack:

```bash
knot stack restart myproject
```

---

## Deleting a Stack

Delete a stack and all its spaces:

```bash
# With confirmation prompt
knot stack delete myproject

# Skip confirmation
knot stack delete myproject -y
```

This permanently deletes all spaces in the stack and all their data.

---

## Validating Templates

Validate a template file without creating it:

```bash
knot stack validate lamp.toml
# Stack definition is valid.
```

This checks for:
- Required fields (`name`, `template_id`)
- Duplicate space names
- Invalid dependency references
- Circular dependencies
- Invalid port forward references
- Port number ranges

Template files can be TOML or JSON. The format is detected by file extension. TOML files use human-friendly names for templates, scripts, and groups (these are resolved to IDs automatically). JSON files use IDs directly, matching the API request format.

**TOML format** (`lamp.toml`):
```toml
name = "LAMP Stack"
description = "A LAMP development stack"

[[spaces]]
name = "db"
template = "mysql-8"
description = "MySQL database"

[[spaces]]
name = "web"
template = "apache-2.4"
depends_on = ["db"]
```

**JSON format** (`lamp.json`):
```json
{
  "name": "LAMP Stack",
  "description": "A LAMP development stack",
  "spaces": [
    {
      "name": "db",
      "template_id": "template-uuid-here",
      "description": "MySQL database"
    },
    {
      "name": "web",
      "template_id": "template-uuid-here",
      "depends_on": ["db"]
    }
  ]
}
```

---

## Full Workflow Example

```bash
# 1. Create a stack template from a TOML or JSON file
knot stack create-def lamp.toml
# Stack definition "lamp-stack" created.

# Or from a JSON file:
# knot stack create-def lamp.json

# 2. List available templates
knot stack list-defs
# Name          Scope      Zones  Spaces  Active
# lamp-stack    user   all    3       yes

# 3. Create a stack from the template
knot stack create lamp-stack myproject
#   Created space "myproject-db" (abc-123)
#   Created space "myproject-web" (def-456)
#   Created space "myproject-cache" (ghi-789)
#
# Stack "myproject" created from definition "lamp-stack" with 3 space(s).
# Run 'knot stack start myproject' to start all spaces.

# 4. Start the stack
knot stack start myproject
# Starting stack: myproject
# Stack started: myproject

# 5. Check status
knot stack list
# Stack          Spaces                       Health
# myproject      myproject-db (Running)       Healthy
#                myproject-web (Running)      Healthy
#                myproject-cache (Running)    Healthy

# 6. Stop the stack
knot stack stop myproject
# Stopping stack: myproject
# Stack stopped: myproject

# 7. Delete the stack
knot stack delete myproject -y
#   Deleted space "myproject-db"
#   Deleted space "myproject-web"
#   Deleted space "myproject-cache"
# Stack "myproject" deleted.
```

---

## Stacks in the Web Interface

Stack templates are visible on the **Stack Templates** page in the web interface. The page shows all available templates with their scope, status, space count, and zone restrictions. You can view template details including components, dependencies, and port forwards.

Stack templates are managed exclusively through the CLI — the web interface is for viewing only.

---

## Stacks from Scripts

The `knot.stack` library provides the same operations for use in scripts:

```python
import knot.stack as stack

# Create a stack from a template
result = stack.create("lamp-stack", "myproject")
print(f"Created {len(result['spaces'])} spaces")

# Start the stack
stack.start("myproject")

# List all stacks
for s in stack.list():
    running = sum(1 for sp in s['spaces'] if sp['is_running'])
    print(f"{s['name']}: {running}/{len(s['spaces'])} running")

# Stop and delete
stack.stop("myproject")
stack.delete("myproject")
```

See the [knot.stack library reference](../../scripting/libraries/stack/) for the full API.
