---
title: Scripting
weight: 125
---

Knot includes a powerful scripting system based on **Scriptling**, a Python-like scripting language. Scripts can automate tasks, extend functionality, and be exposed as MCP tools for AI assistants.

---

## Overview

Scripts in Knot can serve multiple purposes:

- **Automation**: Automate repetitive tasks like space management, configuration, or deployment
- **MCP Tools**: Create custom tools that AI assistants can discover and execute
- **Startup/Shutdown**: Define scripts that run when spaces start or stop
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

## Execution Environments

Knot provides three distinct execution environments, each with different capabilities:

| Environment | Used By | System Access | Best For |
|-------------|---------|---------------|----------|
| **Local** | CLI `knot run-script` | Full (host) | Local development and testing |
| **MCP** | AI tool scripts | None | Safe AI tool execution |
| **Remote** | Space execution | Full (container) | Scripts in user spaces |

See [Execution Environments](environments/) for detailed information about each environment and library availability.

---

## Creating Scripts

Scripts are created and managed through the web interface or CLI. The script editor includes:

- Syntax highlighting
- Auto-completion for available libraries
- Parameter schema definition (for MCP tools)
- Keyword tagging for tool discovery

### Example: Simple Script

```python
import knot.space as space

# List all spaces
spaces = space.list()
for s in spaces:
    print(f"Space: {s['name']} (Status: {s['status']})")
```

### Example: MCP Tool

```python
import scriptling.mcp.tool as tool

# Get parameters with type-safe functions
name = tool.get_string("name")
count = tool.get_int("count", 1)  # with default

# Do your work
results = []
for i in range(count):
    results.append(f"{name}_{i}")

# Return output
tool.return_string("\n".join(results))
```

With parameter schema defined in TOML:

```toml
[[parameters]]
name = "name"
type = "string"
description = "The base name"
required = true

[[parameters]]
name = "count"
type = "number"
description = "Number of items to generate"
required = false
```

---

## Running Scripts

### Local Execution

```bash
# Run a script locally
knot run-script myscript.py

# With arguments
knot run-script myscript.py arg1 arg2

# With piped input
echo "input data" | knot run-script myscript.py
```

### Remote Execution (in a Space)

```bash
# Run script in a space
knot space run-script myspace myscript

# With piped input
echo "data" | knot space run-script myspace myscript
```

---

## Libraries

Scripts have access to several library namespaces:

### knot.* Libraries

Knot-specific libraries for interacting with the platform:

| Library | Description |
|---------|-------------|
| `knot.space` | Space management operations |
| `knot.ai` | AI completion functions |
| `knot.mcp` | MCP tool interaction |
| `knot.skill` | Skills management |
| `knot.template` | Template management |
| `knot.volume` | Volume management |
| `knot.user` | User management |
| `knot.group` | Group management |
| `knot.role` | Role management |
| `knot.vars` | Variables management |
| `knot.permission` | Permission checking |

See [Library Reference](libraries/) for detailed documentation.

### scriptling.* Libraries

Scriptling runtime libraries for general scripting:

| Library | Description |
|---------|-------------|
| `scriptling.ai` | AI and LLM functions |
| `scriptling.ai.agent` | Agentic AI loop with automatic tool execution |
| `scriptling.mcp` | MCP tool helpers |
| `scriptling.mcp.tool` | MCP tool parameter access |
| `scriptling.runtime` | Background tasks and async execution |
| `scriptling.runtime.kv` | Thread-safe key-value store |
| `scriptling.runtime.sync` | Concurrency primitives |
| `scriptling.console` | Console input/output |
| `scriptling.toon` | TOON encoding/decoding |

For detailed documentation on scriptling libraries, see the [Scriptling Documentation](https://scriptling.dev/docs).

### Standard Libraries

Python-compatible standard libraries are available:

- `json`, `base64`, `html`, `math`, `random`, `statistics`
- `time`, `datetime`, `re`, `string`, `textwrap`
- `functools`, `itertools`, `collections`, `hashlib`
- `platform`, `urllib`, `uuid`

### Extended Libraries

Additional libraries (availability depends on environment):

- `requests` - HTTP client
- `subprocess` - Process execution (not in MCP environment)
- `os`, `pathlib`, `sys` - System access (not in MCP environment)
- `yaml` - YAML parsing
- `secrets` - Cryptographic random numbers
- `wait_for` - Wait for conditions

---

## What's Next

- [Execution Environments](environments/) - Detailed environment capabilities
- [Library Reference](libraries/) - knot.* library documentation
- [MCP Tool Authoring](mcp-tools/) - Creating MCP tools
- [Startup/Shutdown Scripts](../startup-scripts/) - Space lifecycle scripts
