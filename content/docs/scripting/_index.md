---
title: Scripting
weight: 125
---

Knot includes a powerful scripting system based on **Scriptling**, a Python-like scripting language. Scripts can automate tasks, extend functionality, and be exposed as MCP tools for AI assistants.

For the complete language reference including syntax, types, control flow, functions, and classes, see the [Scriptling Language Guide](https://scriptling.dev/docs/language/).

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

Knot provides three distinct execution environments, each with different capabilities and library availability.

| Environment | Used By | System Access |
|-------------|---------|---------------|
| **Local** | CLI `knot run-script` | Full (host) |
| **MCP** | AI tool scripts | None |
| **Remote** | Space execution | Full (container) |

See [Execution Environments](environments/) for detailed information about each environment, security considerations, and the complete library availability matrix.

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

- **knot.*** - Knot-specific libraries for platform interaction (see [Library Reference](libraries/))
- **scriptling.*** - Scriptling runtime libraries for AI/LLM integration, MCP support, and concurrency
- **Standard libraries** - Python-compatible libraries like `json`, `math`, `re`, `datetime`
- **Extended libraries** - Additional libraries like `requests`, `yaml`, `toml`

For detailed documentation on scriptling.* and standard libraries, see the [Scriptling Libraries Reference](https://scriptling.dev/docs/libraries/).

Library availability varies by execution environment. See [Execution Environments](environments/) for the complete library availability matrix.

---

## What's Next

- [Scriptling Language Guide](https://scriptling.dev/docs/language/) - Complete language reference
- [Execution Environments](environments/) - Detailed environment capabilities
- [Library Reference](libraries/) - knot.* library documentation
- [MCP Tool Authoring](mcp-tools/) - Creating MCP tools
- [Startup/Shutdown Scripts](../startup-scripts/) - Space lifecycle scripts
