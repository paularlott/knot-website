---
title: Using Stacks
weight: 20
---

Once you have a stack definition, you can create stacks from it. This page covers creating, starting, stopping, and deleting stacks.

---

## Creating a Stack

Use the `knot stack create` command to create spaces from a definition:

```bash
knot stack create <definition> <prefix> [name]
```

- **`definition`** — the name of the stack definition
- **`prefix`** — prefix for space names (spaces are named `prefix-name`)
- **`name`** — stack name used to group spaces (optional, defaults to prefix)

```bash
# Create from the "lamp-stack" definition with prefix "myproject"
knot stack create lamp-stack myproject

# Create with a different stack name
knot stack create lamp-stack myproject production
```

This creates spaces named `myproject-db`, `myproject-web`, and `myproject-cache` (one per space in the definition, named `prefix-name`). Each space is created with:

- The template specified in the definition
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

This groups spaces by their stack name and shows the status of each space:

```
Stack          Spaces
myproject      myproject-db (Stopped)
               myproject-web (Stopped)
               myproject-cache (Stopped)
```

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

## Full Workflow Example

```bash
# 1. Create a stack definition from a TOML file
knot stack create-def lamp.toml
# Stack definition "lamp-stack" created.

# 2. List available definitions
knot stack list-defs
# Name          Scope      Zones  Spaces  Active
# lamp-stack    personal   all    3       yes

# 3. Create a stack from the definition
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
# Stack          Spaces
# myproject      myproject-db (Running)
#                myproject-web (Running)
#                myproject-cache (Running)

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

Stack definitions are visible on the **Stacks** page in the web interface. The page shows all available definitions with their scope, status, space count, and zone restrictions. You can view definition details including components, dependencies, and port forwards.

Stack definitions are managed exclusively through the CLI — the web interface is for viewing only.

---

## Stacks from Scripts

The `knot.stack` library provides the same operations for use in scripts:

```python
import knot.stack as stack

# Create a stack from a definition
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
