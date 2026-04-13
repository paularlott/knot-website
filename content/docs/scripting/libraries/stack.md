---
title: knot.stack
weight: 15
---

The `knot.stack` library provides stack definition and stack lifecycle functions. Stack definitions are blueprints describing which spaces make up a stack and how they are wired together. When you create a stack from a definition, spaces are created with the stack field set, dependencies resolved, and port forwards applied.

---

## Functions

### Definition Management

| Function | Description |
|----------|-------------|
| `list_defs()` | List all stack definitions visible to the current user |
| `get_def(name)` | Get a definition by name or ID |
| `create_def(name, ...)` | Create a new stack definition |
| `update_def(name, **fields)` | Update an existing definition |
| `delete_def(name)` | Delete a definition |

### Stack Operations

| Function | Description |
|----------|-------------|
| `create(definition_name, prefix, stack_name=None)` | Create spaces from a definition |
| `delete(stack_name)` | Delete all spaces in a stack |
| `start(stack_name)` | Start all spaces in a stack in dependency order |
| `stop(stack_name)` | Stop all spaces in reverse dependency order |
| `restart(stack_name)` | Restart all spaces in a stack |
| `list()` | List stacks by grouping spaces by stack name |

---

## Usage

```python
import knot.stack as stack

# List available definitions
defs = stack.list_defs()
for d in defs:
    print(f"{d['name']}: {len(d['spaces'])} spaces")

# Get definition details
defn = stack.get_def("lamp")
print(f"Definition: {defn['name']}")
for comp in defn['spaces']:
    print(f"  {comp['name']}: {comp.get('template_id', 'unknown')}")

# Create a stack from a definition
result = stack.create("lamp", "myproject")
for name, space_id in result['spaces'].items():
    print(f"  {name}: {space_id}")

# Start the stack
stack.start("myproject")

# List all stacks
for s in stack.list():
    print(f"{s['name']}: {len(s['spaces'])} spaces")

# Stop and delete
stack.stop("myproject")
stack.delete("myproject")
```

---

## Creating Definitions

```python
import knot.stack as stack

# Create a personal stack definition
stack.create_def(
    "my-stack",
    description="My development stack",
    scope="personal",
    spaces=[
        {
            "name": "db",
            "template": "mysql-8",
            "description": "MySQL database",
            "custom_fields": [
                {"name": "MYSQL_ROOT_PASSWORD", "value": "secret"},
                {"name": "MYSQL_DATABASE", "value": "appdb"},
            ],
            "port_forwards": [
                {"to_space": "web", "local_port": 3306, "remote_port": 3306},
            ],
        },
        {
            "name": "web",
            "template": "apache-2.4",
            "depends_on": ["db"],
        },
    ],
)
```

---

## Creating from a Definition

```python
import knot.stack as stack

# Create spaces from the "lamp" definition
# Spaces will be named: webapp-db, webapp-web
# and grouped under the stack name "webapp"
result = stack.create("lamp", "webapp")

# Or use a different stack name from the prefix
result = stack.create("lamp", "webapp", stack_name="my-lamp-stack")
```

---

## Definition Properties

Definitions returned by `get_def()` contain:
- `id` - Stack definition ID
- `name` - Definition name
- `description` - Description
- `user_id` - Owner user ID (empty for global definitions)
- `active` - Whether the definition is available for creating stacks
- `groups` - List of group IDs allowed to create instances
- `zones` - List of zone restrictions
- `spaces` - List of space dicts (see below)

---

## Backward Compatibility

The `knot.space` functions `get_stack` and `set_stack` read and write the `Space.Stack` string field on individual spaces. They are complementary to this library — `knot.stack.create` sets the stack field automatically when creating spaces from a definition.
