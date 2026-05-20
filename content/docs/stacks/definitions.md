---
title: Stack Definitions
weight: 10
---

Stack definitions are TOML files that describe the spaces, dependencies, and configuration that make up a stack. This page covers the complete TOML format with all available options.

---

## Minimal Example

```toml
name = "web-app"
description = "Simple web application"

[[spaces]]
name = "web"
template = "ubuntu-latest"
```

This creates a single-space stack. The space uses the `ubuntu-latest` template and is named `web`.

---

## Complete Example

```toml
name = "lamp-stack"
description = "Linux, Apache, MySQL, PHP stack"
scope = "user"
groups = ["developers"]
zones = ["us-east"]

[[spaces]]
name = "db"
description = "MySQL database server"
template = "mysql-8"
shell = "/bin/bash"
startup_script = "init-db"

[[spaces.custom_fields]]
name = "MYSQL_ROOT_PASSWORD"
value = "secret"

[[spaces.custom_fields]]
name = "MYSQL_DATABASE"
value = "appdb"

[[spaces]]
name = "web"
description = "Apache web server"
template = "apache-2.4"
depends_on = ["db"]

[[spaces.port_forwards]]
to_space = "db"
local_port = 6379
remote_port = 6379

[[spaces]]
name = "cache"
description = "Redis Cache"
template = "redis-7"
```

---

## Top-Level Options

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `name` | string | Yes | — | Unique name for the stack definition |
| `description` | string | No | `""` | Description shown in the UI and CLI |
| `scope` | string | No | `"user"` | Visibility scope: `user` or `global` |
| `groups` | list | No | `[]` | Groups allowed to create stacks from this definition (global scope only, names resolved to IDs) |
| `zones` | list | No | `[]` | Zone restrictions — definition is only available in listed zones (empty = all zones) |

### Scope

- **`user`** — Only visible to the creator. Use for personal development stacks.
- **`global`** — Visible to all users (subject to group restrictions). Use for shared stacks that teams can create instances of.

---

## Space Configuration

Each `[[spaces]]` block defines a space in the stack. The `name` is used as the identifier — spaces are named `{prefix}-{name}` when the stack is created, and `name` is used in dependency and port forward references.

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `name` | string | Yes | — | Space name — used for naming (`prefix-name`), dependencies, and port forward targets |
| `template` | string | Yes | — | Name of the template to use (resolved to template ID) |
| `description` | string | No | `""` | Space description |
| `shell` | string | No | template default | Override the default shell |
| `startup_script` | string | No | — | Name of a script to run on startup (resolved to script ID) |
| `depends_on` | list | No | `[]` | List of space names this space depends on |

### Dependencies

Dependencies control startup order. When starting a stack, spaces are started after all their dependencies are running. When stopping, spaces are stopped before the spaces they depend on.

```toml
[[spaces]]
name = "web"
template = "apache-2.4"
depends_on = ["db", "cache"]

[[spaces]]
name = "db"
template = "mysql-8"

[[spaces]]
name = "cache"
template = "redis-7"
```

In this example, `web` will not start until both `db` and `cache` are running.

---

## Custom Fields

Custom fields set environment variables or configuration values on a space. Each `[[spaces.custom_fields]]` block within a space defines a name-value pair.

```toml
[[spaces]]
name = "db"
template = "mysql-8"

[[spaces.custom_fields]]
name = "MYSQL_ROOT_PASSWORD"
value = "secret"

[[spaces.custom_fields]]
name = "MYSQL_DATABASE"
value = "appdb"

[[spaces.custom_fields]]
name = "MYSQL_USER"
value = "appuser"
```

Custom fields are applied when the space is created and can be modified afterwards through the space settings.

---

## Port Forwards

Port forwards configure network connectivity between spaces. Each `[[spaces.port_forwards]]` block within a space defines a forwarding rule.

```toml
[[spaces]]
name = "web"
template = "apache-2.4"
depends_on = ["db"]

[[spaces.port_forwards]]
to_space = "db"
local_port = 3306
remote_port = 3306
```

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `to_space` | string | Yes | Name of the target space |
| `local_port` | integer | Yes | Port on the source space |
| `remote_port` | integer | Yes | Port on the target space |

Port forwards are created as persistent forwards — they survive space restarts. The `to_space` value references another space by its `name` in the same stack definition.

---

## CLI Workflow

```bash
# Create a stack definition
knot stack create-def lamp.toml

# List all definitions
knot stack list-defs

# View detailed definition info
knot stack list-defs --details

# Disable a definition (prevents creating stacks from it)
knot stack disable-def lamp-stack

# Re-enable a definition
knot stack enable-def lamp-stack

# Update a definition
knot stack apply lamp.toml

# Delete a definition
knot stack delete-def lamp-stack
```

---

## Scripting

Stack definitions can also be created and managed from scripts using the `knot.stack` library:

```python
import knot.stack as stack

# Create a definition programmatically
stack.create_def(
    "my-stack",
    description="My development stack",
    scope="user",
    spaces=[
        {
            "name": "web",
            "template": "ubuntu-latest",
            "depends_on": ["db"],
        },
        {
            "name": "db",
            "template": "mysql-8",
            "custom_fields": [
                {"name": "MYSQL_ROOT_PASSWORD", "value": "secret"},
            ],
        },
    ],
)
```

See the [knot.stack library reference](../../scripting/libraries/stack/) for the full API.
