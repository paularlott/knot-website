---
title: Scripting
weight: 85
---

Knot includes a powerful scripting system based on **Scriptling**, a Python-like scripting language. Scripts can automate tasks, extend functionality, and be exposed as MCP tools for AI assistants.

For the complete language reference including syntax, types, control flow, functions, and classes, see the [Scriptling Language Guide](https://scriptling.dev/reference/).

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

| Type     | Description                                |
| -------- | ------------------------------------------ |
| `script` | Standard executable script (default)       |
| `lib`    | Library module for import by other scripts |
| `tool`   | MCP tool exposed to AI assistants          |

---

## Global vs User Scripts

Scripts can be either global or user-specific:

- **Global Scripts**: Available to all users (with optional group restrictions). Created by administrators.
- **User Scripts**: Personal scripts owned by individual users. Only visible to the owner.

User scripts with the same name override (shadow) global scripts, allowing users to customize behavior.

---

## Creating Scripts

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
knot script list

# Show script details
knot script show <script-name>

# Delete a script
knot script delete <script-name>
```

---

## Running Scripts

### Remote Execution (in a Space)

Run scripts inside a running space:

```bash
# Run script in a space
knot space run-script <space-name> <script-name>

# With piped input
echo "data" | knot space run-script <space-name> <script-name>
```

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

### MCP Environment

**Used by:** AI assistants executing MCP tools

The most restricted environment. System access libraries (`os`, `pathlib`, `subprocess`, `sys`) are not available. Libraries are fetched from the server only.

```python
import scriptling.mcp.tool as tool

name = tool.get_string("name", "World")
tool.return_string(f"Hello, {name}!")
```

### Remote Environment

**Command:** `knot space run-script`

Scripts run inside the container with full capabilities within that container's isolation. All libraries are loaded on-demand from the server.

```bash
knot space run-script myspace myscript arg1 arg2
```

**Note:** Requires an active agent connection. `scriptling.console` and `scriptling.ai.agent.interact` are available for interactive sessions.

### External Environment

**Used by:** Standalone [scriptling](https://scriptling.dev/) scripts using the `knot.zip` package

Scripts running outside knot entirely, using the published `knot.zip` package. Requires explicit configuration via `knot.apiclient` or environment variables — see [Using knot.\* Libraries](using-libraries/) for details.

```bash
scriptling --package=https://knot.example.com/packages/knot.zip myscript.py
```

### Plugin Scopes

Every script execution in knot's embedded environments (MCP, Remote) gets its own **isolated plugin scope** via the [`scriptling.plugin`](https://scriptling.dev/) library. A plugin that a script loads at runtime with `scriptling.plugin.load()` is visible only to that execution — it cannot leak into another user's script or another tool invocation. The scope is released automatically when the script finishes.

The transports a scope will accept depend on the environment:

| Environment                | HTTP(S) plugins | Stdio executable plugins |
| -------------------------- | --------------- | ------------------------ |
| MCP / event sink / health  | ✓               | ✗                        |
| Remote (in-space)          | ✓               | ✓                        |

Server-side scripts (MCP tools, event sinks, health checks) run on the knot server and are restricted to HTTP(S) plugin endpoints — they cannot spawn arbitrary executables on the server. In-space (Remote) scripts already run inside a container with subprocess access, so both transports are permitted.

---

## Library Availability

### Standard & Extended Libraries

| Library            | MCP | Remote | External |
| ------------------ | --- | ------ | -------- |
| Standard Libraries | ✓   | ✓      | ✓        |
| requests           | ✓   | ✓      | ✓        |
| secrets            | ✓   | ✓      | ✓        |
| yaml / toml        | ✓   | ✓      | ✓        |
| shlex              | ✓   | ✓      | ✓        |
| subprocess         | ✗   | ✓      | ✓        |
| os / pathlib       | ✗   | ✓      | ✓        |
| glob               | ✗   | ✓      | ✓        |
| tempfile           | ✗   | ✓      | ✓        |
| shutil             | ✗   | ✓      | ✓        |
| zipfile            | ✗   | ✓      | ✓        |
| tarfile            | ✗   | ✓      | ✓        |
| sys                | ✗   | ✓      | ✓        |

### scriptling.\* Libraries

| Library                              | MCP                 | Remote              | External |
| ------------------------------------ | ------------------- | ------------------- | -------- |
| scriptling.secret                    | {{< pro-badge >}}\* | {{< pro-badge >}}\* | ✓        |
| scriptling.ai                        | ✓                   | ✓                   | ✓        |
| scriptling.ai.agent                  | ✓                   | ✓                   | ✓        |
| scriptling.ai.agent.interact         | ✗                   | ✓                   | ✓        |
| scriptling.mcp / scriptling.mcp.tool | ✓                   | ✓                   | ✓        |
| scriptling.console                   | ✗                   | ✓                   | ✓        |
| scriptling.grep                      | ✗                   | ✓                   | ✓        |
| scriptling.find                      | ✗                   | ✓                   | ✓        |
| scriptling.csv                       | ✓                   | ✓                   | ✓        |
| scriptling.xml                       | ✓                   | ✓                   | ✓        |
| scriptling.sed                       | ✗                   | ✓                   | ✓        |
| scriptling.runtime                   | ✗                   | ✓                   | ✓        |
| scriptling.websocket                 | ✓                   | ✓                   | ✓        |
| scriptling.template.html             | ✓                   | ✓                   | ✓        |
| scriptling.template.text             | ✓                   | ✓                   | ✓        |
| scriptling.net.resolve               | ✓                   | ✓                   | ✓        |
| scriptling.provision.file            | ✗                   | ✓                   | ✓        |
| scriptling.plugin                    | ✓ †                 | ✓                   | ✓        |

\* Requires a Pro license for secret provider access (Vault, 1Password). Standalone scriptling has built-in secret support.

† In server-side environments (MCP, event sink, and health check scripts) the plugin scope is **HTTP(S) only** — scripts may connect to remote HTTP(S) plugin endpoints but cannot spawn local executables on the knot server. Remote (in-space) scripts may load both HTTP(S) and stdio executable plugins. Each script execution gets its own isolated plugin scope, so plugins loaded by one execution are invisible to every other user and execution. In the External environment, plugin transport and scoping are governed by [scriptling](https://scriptling.dev/) itself, not knot.

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

## MCP Tools

Scripts of type `tool` are exposed as MCP tools for AI assistants. These tools can be discovered and executed by AI systems like Claude or ChatGPT.

### Parameter Schema

Define parameters in TOML format:

```toml
requires_approval = true

[[parameters]]
name = "name"
type = "string"
description = "Name of the space"
required = true
```

Set `requires_approval = true` for tools that write, mutate, delete, start, stop, or execute commands. When such a tool is called from the web assistant, Knot asks the browser user to approve it before execution. External MCP clients connected to `/mcp` are not prompted by the browser approval UI.

### Parameter Types

| Type      | Description      |
| --------- | ---------------- |
| `string`  | Text value       |
| `number`  | Numeric value    |
| `boolean` | True/false value |
| `array`   | List of values   |

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

| Permission            | Description                            |
| --------------------- | -------------------------------------- |
| `MANAGE_OWN_SCRIPTS`  | Create, update, and delete own scripts |
| `MANAGE_SCRIPTS`      | Manage global scripts (admin)          |
| `EXECUTE_OWN_SCRIPTS` | Execute own scripts                    |
| `EXECUTE_SCRIPTS`     | Execute global scripts                 |

---

## What's Next

- [Script Examples](examples/) - Practical script examples
- [Scriptling Language Guide](https://scriptling.dev/reference/) - Complete language reference
- [Using knot.\* Libraries](using-libraries/) - Configuration and authentication
- [Library Reference](/reference/libraries/) - knot.\* library documentation
- [Startup/Shutdown Scripts](../spaces/startup-scripts/) - Space lifecycle scripts
