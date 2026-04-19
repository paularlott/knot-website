---
title: Scripts
weight: 85
---

Scripts in **knot** are Python-like programs that can automate tasks, extend functionality, and be exposed as MCP tools for AI assistants. Scripts are written using the Scriptling language and can interact with knot through built-in libraries.

---

## Overview

Scripts can serve multiple purposes in knot:

- **Automation**: Automate space management, configuration, or deployment tasks
- **MCP Tools**: Create custom tools that AI assistants can discover and execute
- **Startup/Shutdown**: Define scripts that run when spaces start or stop (configured in templates)
- **Libraries**: Create reusable code modules that can be imported by other scripts

---

## Script Types

When creating a script, you specify its type:

| Type | Description |
|------|-------------|
| `script` | Standard executable script (default) |
| `lib` | Library module for import by other scripts |
| `tool` | MCP tool exposed to AI assistants |

---

## Global vs User Scripts

Scripts can be either global or user-specific:

- **Global Scripts**: Available to all users (with optional group restrictions). Created by administrators.
- **User Scripts**: Personal scripts owned by individual users. Only visible to the owner.

User scripts with the same name override (shadow) global scripts, allowing users to customize behavior.

---

## Creating a Script

### Via Web Interface

1. From the menu, select **`Scripts`**, then click **`New Script`**.
2. Fill in the required fields:
   - **`Name`**: A descriptive name to identify the script
   - **`Description`**: Brief description of what the script does
   - **`Type`**: Script type (script, lib, or tool)
   - **`Content`**: The script code
   - **`Active`**: Whether the script is enabled
3. For MCP tools, also define:
   - **`Parameter Schema`**: TOML defining input parameters
   - **`Keywords`**: Tags for tool discovery
   - **`Discoverable`**: Whether the tool is visible to AI assistants

### Via CLI

```bash
# List scripts
knot scripts list

# Show script details
knot scripts show <script-name>

# Delete a script
knot scripts delete <script-name>
```

---

## Running Scripts

### Local Execution

Run scripts on your local machine:

```bash
# Run a script
knot run-script myscript

# With arguments
knot run-script myscript arg1 arg2

# With host-owned secret providers for scriptling.secret
knot run-script --secret-config ./secrets.toml myscript

# With piped input
echo "input data" | knot run-script myscript
```

### Remote Execution (in a Space)

Run scripts inside a running space:

```bash
# Run script in a space
knot space run-script <space-name> <script-name>

# With piped input
echo "data" | knot space run-script <space-name> <script-name>
```

---

## MCP Tools

Scripts of type `tool` are exposed as MCP tools for AI assistants. These tools can be discovered and executed by AI systems like Claude or ChatGPT.

### Parameter Schema

Define parameters in TOML format:

```toml
description = "Create a new development space"
keywords = ["create", "space", "new", "environment"]

[[parameters]]
name = "name"
type = "string"
description = "Name of the space"
required = true

[[parameters]]
name = "template"
type = "string"
description = "Template to use"
required = true

[[parameters]]
name = "description"
type = "string"
description = "Optional description"
required = false
```

### Parameter Types

| Type | Description |
|------|-------------|
| `string` | Text value |
| `number` | Numeric value |
| `boolean` | True/false value |
| `array` | List of values |

### Example MCP Tool

```python
import scriptling.mcp.tool as tool
import knot.space as space

# Get parameters
name = tool.get_string("name")
template = tool.get_string("template")
description = tool.get_string("description", "")

# Create the space
space_id = space.create(name, template, description=description)

# Return result
tool.return_string(f"Space '{name}' created with ID: {space_id}")
```

---

## Access Control

### Zone Restrictions

Scripts can be limited to specific zones:

- If no zones are specified, the script is available in all zones
- Zones prefixed with `!` are exclusions (e.g., `!us-west-1` excludes that zone)

### Group Restrictions

Global scripts can be restricted to specific user groups. Only users in those groups can see and execute the script.

---

## Permissions

| Permission | Description |
|------------|-------------|
| `MANAGE_OWN_SCRIPTS` | Create, update, and delete own scripts |
| `MANAGE_SCRIPTS` | Manage global scripts (admin) |
| `EXECUTE_OWN_SCRIPTS` | Execute own scripts |
| `EXECUTE_SCRIPTS` | Execute global scripts |

---

## What's Next

- [Scripting Reference](../scripting/) - Complete language and library documentation
- [Execution Environments](../scripting/environments/) - Detailed environment capabilities
- [Library Reference](../scripting/libraries/) - knot.* library documentation
- [Startup/Shutdown Scripts](../spaces/startup-scripts/) - Space lifecycle scripts
