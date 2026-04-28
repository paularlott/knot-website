---
title: Scripting
weight: 125
---

Knot includes a powerful scripting system based on **Scriptling**, a Python-like scripting language. Scripts can automate tasks, extend functionality, and be exposed as MCP tools for AI assistants.

For the complete language reference including syntax, types, control flow, functions, and classes, see the [Scriptling Language Guide](https://scriptling.dev/docs/language/).

---

## Script Types

When creating a script, you specify its type:

| Type     | Description                                |
| -------- | ------------------------------------------ |
| `script` | Standard executable script (default)       |
| `lib`    | Library module for import by other scripts |
| `tool`   | MCP tool exposed to AI assistants          |

---

## Execution Environments

Knot provides three distinct execution environments, each tailored for specific use cases with different library availability and security constraints.

| Environment  | Used By               | System Access         | Best For                              |
| ------------ | --------------------- | --------------------- | ------------------------------------- |
| **MCP**      | AI tool scripts       | None                  | Safe AI tool execution                |
| **Remote**   | Space execution       | Full (container)      | Scripts in user spaces/containers     |
| **External** | Standalone scriptling | Host (scriptling-cli) | Scripts outside knot using `knot.zip` |

```
Is it an MCP tool for AI?
├─ YES → MCP Environment
└─ NO → Is it running in a space/container?
    ├─ YES → Remote Environment
    └─ NO → External Environment
```

---

## MCP Environment

**Used by:** AI assistants executing MCP tools

The most restricted environment. System access libraries (`os`, `pathlib`, `subprocess`, `sys`) are not available. Libraries are fetched from the server only.

```python
import scriptling.mcp.tool as tool

name = tool.get_string("name", "World")
tool.return_string(f"Hello, {name}!")
```

---

## Remote Environment

**Command:** `knot space run-script`

Scripts run inside the container with full capabilities within that container's isolation. All libraries are loaded on-demand from the server.

```bash
knot space run-script myspace myscript arg1 arg2
```

**Note:** Requires an active agent connection. `scriptling.console` and `scriptling.ai.agent.interact` are available for interactive sessions.

---

## External Environment

**Used by:** Standalone [scriptling](https://scriptling.dev/) scripts using the `knot.zip` package

Scripts running outside knot entirely, using the published `knot.zip` package. Requires explicit configuration via `knot.apiclient` or environment variables — see [Using knot.\* Libraries](using-libraries/) for details.

```bash
scriptling --package=https://knot.example.com/packages/knot.zip myscript.py
```

---

## Library Availability

### Standard & Extended Libraries

| Library            | MCP | Remote | External |
| ------------------ | --- | ------ | -------- |
| Standard Libraries | ✓   | ✓      | ✓        |
| requests           | ✓   | ✓      | ✓        |
| secrets            | ✓   | ✓      | ✓        |
| yaml / toml        | ✓   | ✓      | ✓        |
| subprocess         | ✗   | ✓      | ✓        |
| os / pathlib       | ✗   | ✓      | ✓        |
| sys                | ✗   | ✓      | ✓        |

### scriptling.\* Libraries

| Library                              | MCP | Remote | External |
| ------------------------------------ | --- | ------ | -------- |
| scriptling.secret                    | ✓   | ✓      | ✗        |
| scriptling.ai                        | ✓   | ✓      | ✓        |
| scriptling.ai.agent                  | ✓   | ✓      | ✓        |
| scriptling.ai.agent.interact         | ✗   | ✓      | ✓        |
| scriptling.mcp / scriptling.mcp.tool | ✓   | ✓      | ✓        |
| scriptling.console                   | ✗   | ✓      | ✓        |
| scriptling.grep                      | ✗   | ✓      | ✓        |
| scriptling.sed                       | ✗   | ✓      | ✓        |
| scriptling.runtime                   | ✗   | ✓      | ✓        |
| scriptling.websocket                 | ✓   | ✓      | ✓        |
| scriptling.template.html             | ✓   | ✓      | ✓        |
| scriptling.template.text             | ✓   | ✓      | ✓        |

### knot.\* Libraries

All `knot.*` libraries are available in all three environments. In MCP and Remote contexts the Go runtime provides the transport automatically — no configuration needed. In External contexts `knot.apiclient` must be configured.

| Library         | MCP | Remote | External |
| --------------- | --- | ------ | -------- |
| knot.space      | ✓   | ✓      | ✓        |
| knot.ai         | ✓   | ✓      | ✓        |
| knot.mcp        | ✓   | ✓      | ✓        |
| knot.user       | ✓   | ✓      | ✓        |
| knot.group      | ✓   | ✓      | ✓        |
| knot.role       | ✓   | ✓      | ✓        |
| knot.template   | ✓   | ✓      | ✓        |
| knot.vars       | ✓   | ✓      | ✓        |
| knot.volume     | ✓   | ✓      | ✓        |
| knot.skill      | ✓   | ✓      | ✓        |
| knot.permission | ✓   | ✓      | ✓        |
| knot.stack      | ✓   | ✓      | ✓        |

---

## Creating Scripts

Scripts are created and managed through the web interface or CLI.

### Example: Simple Script

```python
import knot.space as space

spaces = space.list()
for s in spaces:
    print(f"Space: {s['name']} ({'running' if s['is_running'] else 'stopped'})")
```

### Example: Server-Side Secret Access

`scriptling.secret` is available in Knot's server-side script environments automatically.

```python
import scriptling.secret as secret

db_password = secret.get("vault", "secret/data/prod/database", "password")
api_key = secret.get("op", "Engineering/API Service Key", "credential")
```

### Example: MCP Tool

```python
import scriptling.mcp.tool as tool

name = tool.get_string("name")
count = tool.get_int("count", 1)

results = [f"{name}_{i}" for i in range(count)]
tool.return_string("\n".join(results))
```

With parameter schema in TOML:

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

## What's Next

- [Scriptling Language Guide](https://scriptling.dev/docs/language/) - Complete language reference
- [Using knot.\* Libraries](using-libraries/) - Configuration and authentication
- [Library Reference](libraries/) - knot.\* library documentation
- [Startup/Shutdown Scripts](../spaces/startup-scripts/) - Space lifecycle scripts
