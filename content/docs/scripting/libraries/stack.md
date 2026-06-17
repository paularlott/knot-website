---
title: knot.stack
weight: 15
---

The `knot.stack` library provides stack template (definition) management and stack lifecycle functions. Stack templates are blueprints describing which spaces make up a stack and how they are wired together. When you create a stack from a template, spaces are created with the stack field set, dependencies resolved, and port forwards applied.

> The function names use the historical `_def` suffix (short for "definition") — these operate on what the web UI now calls **stack templates**. The two terms are interchangeable.

---

## Functions

### Template Management

| Function | Description |
|----------|-------------|
| `list_defs()` | List all stack templates visible to the current user |
| `get_def(name)` | Get a template by name or ID |
| `create_def(name, ...)` | Create a new stack template |
| `update_def(name, **fields)` | Update an existing template |
| `delete_def(name)` | Delete a template |
| `validate_def(spaces, ...)` | Validate a template without creating it |

### Stack Operations

| Function | Description |
|----------|-------------|
| `create(template_name, prefix, stack_name=None)` | Create spaces from a template |
| `delete(stack_name)` | Delete all spaces in a stack |
| `start(stack_name)` | Start all spaces in a stack in dependency order |
| `stop(stack_name)` | Stop all spaces in reverse dependency order |
| `restart(stack_name)` | Restart all spaces in a stack |
| `list()` | List stacks by grouping spaces by stack name |

---

## Usage

```python
import knot.stack as stack

# List available templates
defs = stack.list_defs()
for d in defs:
    print(f"{d['name']}: {len(d['spaces'])} spaces")

# Get template details
defn = stack.get_def("lamp")
print(f"Template: {defn['name']}")
for comp in defn['spaces']:
    print(f"  {comp['name']}: {comp.get('template_id', 'unknown')}")

# Create a stack from a template
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

## Creating Templates

```python
import knot.stack as stack

# Create a personal stack template
stack.create_def(
    "my-stack",
    description="My development stack",
    scope="user",
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

## Validating Templates

Use `validate_def` to check a template for errors before creating it. This catches structural problems like circular dependencies, missing required fields, and invalid references.

```python
import knot.stack as stack

# Validate before creating
result = stack.validate_def(
    name="my-stack",
    spaces=[
        {"name": "db", "template_id": "template-uuid"},
        {"name": "web", "template_id": "template-uuid", "depends_on": ["db"]},
    ],
)

if result["valid"]:
    print("Template is valid")
else:
    for err in result.get("errors", []):
        if err.get("space"):
            print(f"  [{err['space']}] {err['field']}: {err['message']}")
        else:
            print(f"  {err['field']}: {err['message']}")
```

Validation checks for:
- Required fields (`name`, `template_id`)
- Duplicate space names
- Invalid `depends_on` references
- Circular dependencies
- Invalid `port_forwards.to_space` references
- Port number ranges (1-65535)

---

## Creating from a Template

```python
import knot.stack as stack

# Create spaces from the "lamp" template
# Spaces will be named: webapp-db, webapp-web
# and grouped under the stack name "webapp"
result = stack.create("lamp", "webapp")

# Or use a different stack name from the prefix
result = stack.create("lamp", "webapp", stack_name="my-lamp-stack")
```

---

## Template Properties

Templates returned by `get_def()` contain:
- `id` - Stack definition ID
- `name` - Template name
- `description` - Description
- `user_id` - Owner user ID (empty for global templates)
- `active` - Whether the template is available for creating stacks
- `groups` - List of group IDs allowed to create instances
- `zones` - List of zone restrictions
- `spaces` - List of space dicts (see below)

---

## Backward Compatibility

The `knot.space` functions `get_stack` and `set_stack` read and write the `Space.Stack` string field on individual spaces. They are complementary to this library — `knot.stack.create` sets the stack field automatically when creating spaces from a definition.
