---
description: Automate knot with Scriptling, a Python-like scripting language exposed as MCP tools and libraries.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/scripting/
sources:
    - resource: https://getknot.dev/docs/scripting/
status: stable
tags:
    - scripting
title: Scripting
type: Overview
---
# Scripting

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

Knot has two embedded execution environments — one per execution location — plus standalone scriptling:

| Environment  | Runs                | Used By                                                                    | System Access         |
| ------------ | ------------------- | -------------------------------------------------------------------------- | --------------------- |
| **Server**   | In the knot server  | MCP tool scripts, event sink scripts                                       | None                  |
| **Space**    | In the space (agent)| Startup/shutdown scripts, user scripts, `knot run-script`, health checks, `knot methods register` | Full (container) |
| **External** | Host (scriptling-cli) | Scripts outside knot using `knot.zip`                                   | Host                  |

```
Does the script run in the knot server?
├─ YES → Server environment (MCP tools, event sinks)
└─ NO → Is it running in a space/container?
    ├─ YES → Space environment (one shared library surface for every agent-side context)
    └─ NO → External environment
```

### Server Environment

**Used by:** MCP tool scripts and event sink scripts, executed inside the knot server.

The restricted environment. No system access libraries (`os`, `pathlib`, `subprocess`, `sys`), no `scriptling.runtime`, no `knot.methods`, and `fs` only when `server.script_fs_allowed_paths` is configured. Libraries are fetched from the server only (including user `lib` scripts). Event sinks additionally expose the `knot.event` accessors instead of `emit()`, which prevents sink → event → sink recursion.

```python
import scriptling.mcp.tool as tool

name = tool.get_string("name", "World")
tool.return_string(f"Hello, {name}!")
```

### Space Environment

**Used by:** every script that runs in a space under the agent — startup/shutdown scripts, user scripts (`knot space run-script`, eval), `knot run-script` (eval), health check scripts, and `knot methods register`. Serving and the interactive REPL run on the real Scriptling CLI in the space (Scriptling base images), not the embedded runtime.

Scripts run inside the container with full capabilities within that container's isolation, and every agent-side context shares the same library surface (the scriptling CLI set minus container/nomad, plus all `knot.*` libraries including `knot.methods` and `knot.healthcheck`). All libraries are loaded on-demand from the server.

```bash
knot space run-script myspace myscript arg1 arg2
```

**Note:** Requires an active agent connection. `scriptling.console` and `scriptling.ai.agent.interact` are available for interactive sessions.

### External Environment

**Used by:** Standalone [scriptling](https://scriptling.dev/) scripts using the `knot.zip` package

Scripts running outside knot entirely, using the published `knot.zip` package. Requires explicit configuration via `knot.apiclient` or environment variables — see [Using knot.\* Libraries](scripting/using-libraries.md) for details.

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
| shlex              | ✓   | ✓      | ✓        |
| fs                 | ✓ ¹ | ✓      | ✓        |
| html.parser        | ✓   | ✓      | ✓        |
| logging            | ✓   | ✓      | ✓        |
| subprocess         | ✗   | ✓      | ✓        |
| os / pathlib       | ✗   | ✓      | ✓        |
| glob               | ✗   | ✓      | ✓        |
| tempfile           | ✗   | ✓      | ✓        |
| shutil             | ✗   | ✓      | ✓        |
| zipfile            | ✗   | ✓      | ✓        |
| tarfile            | ✗   | ✓      | ✓        |
| sys                | ✗   | ✓      | ✓        |

¹ On the knot server (MCP tool execution and event sink scripts) `fs` is only registered when the admin configures `server.script_fs_allowed_paths` (flag `--script-fs-allowed-paths`, env `KNOT_SCRIPT_FS_ALLOWED_PATHS`); without it, server-side scripts have no local filesystem access. In spaces (Remote) `fs` is always available, scoped to the container.

### scriptling.\* Libraries

| Library                              | MCP                 | Remote              | External |
| ------------------------------------ | ------------------- | ------------------- | -------- |
| scriptling.secret                    | \* | ✗                   | ✓        |
| scriptling.ai                        | ✓                   | ✓                   | ✓        |
| scriptling.ai.agent                  | ✓                   | ✓                   | ✓        |
| scriptling.ai.tools                  | ✓                   | ✓                   | ✓        |
| scriptling.ai.memory                 | ✗                   | ✓                   | ✓        |
| scriptling.mcp / scriptling.mcp.tool | ✓                   | ✓                   | ✓        |
| scriptling.toon                      | ✓                   | ✓                   | ✓        |
| scriptling.messaging (telegram / discord / slack) | ✓       | ✓                   | ✓        |
| scriptling.grep                      | ✗                   | ✓                   | ✓        |
| scriptling.find                      | ✗                   | ✓                   | ✓        |
| scriptling.csv                       | ✓                   | ✓                   | ✓        |
| scriptling.xml                       | ✓                   | ✓                   | ✓        |
| scriptling.sed                       | ✗                   | ✓                   | ✓        |
| scriptling.similarity                | ✓                   | ✓                   | ✓        |
| scriptling.wait_for                  | ✓                   | ✓                   | ✓        |
| scriptling.template.html             | ✓                   | ✓                   | ✓        |
| scriptling.template.text             | ✓                   | ✓                   | ✓        |
| scriptling.provision.file            | ✗                   | ✓                   | ✓        |
| scriptling.provision.fetch           | ✗                   | ✓                   | ✓        |

\* Requires a Pro license for secret provider access (Vault, 1Password). Standalone scriptling has built-in secret support.

### knot.\* Libraries

In MCP and Remote contexts the Go runtime provides the transport automatically — no configuration needed. In External contexts `knot.apiclient` must be configured. Most `knot.*` libraries are available everywhere, but a few are context-restricted — the [library reference](../../../reference/libraries/) documents the exact Execution Environment for each.

| Library                 | MCP           | Remote        | External          |
| ----------------------- | ------------- | ------------- | ----------------- |
| knot.space              | ✓             | ✓             | ✓                 |
| knot.user               | ✓             | ✓             | ✓                 |
| knot.group              | ✓             | ✓             | ✓                 |
| knot.role               | ✓             | ✓             | ✓                 |
| knot.template           | ✓             | ✓             | ✓                 |
| knot.vars               | ✓             | ✓             | ✓                 |
| knot.volume             | ✓             | ✓             | ✓                 |
| knot.permission         | ✓             | ✓             | ✓                 |
| knot.stack              | ✓             | ✓             | ✓                 |
| knot.pool               | ✓             | ✓             | ✓                 |
| knot.script             | ✓             | ✓             | ✓                 |
| knot.skill              | ✓             | ✓             | ✓                 |
| knot.slash_command      | ✓             | ✓             | ✓                 |
| knot.server             | ✓             | ✓             | ✓                 |
| knot.audit              | ✓ \* | ✓ \* | ✓ \* |
| knot.ai                 | ✓             | ✓             | ✓                 |
| knot.mcp                | ✓             | ✓             | ✓                 |
| knot.apiclient          | ✓ (automatic) | ✓ (automatic) | ✓ (configure first) |
| knot.event              | emit only †   | emit only †   | emit only †       |
| knot.methods            | ✗             | ✓             | ✗                 |
| knot.methods.schema     | ✗             | ✓             | ✗                 |
| knot.healthcheck        | ✗             | ✓             | ✗                 |

\* `knot.audit` requires a Pro license.

† `knot.event` is context-sensitive: `emit()` is available in space scripts, MCP tool scripts, and external scripts. The payload/metadata accessors (`get_string()`, `type()`, `space()`, …) are only available in event sink scripts — see [Events](../../../reference/events/).

Event sink scripts follow the MCP column, except `knot.event` exposes the sink accessors instead of `emit()` and `knot.methods` is not registered. Health check scripts run agent-side in the space and share the full Space environment, including `knot.healthcheck`.

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

- [Script Examples](scripting/examples.md) - Practical script examples
- [Scriptling Language Guide](https://scriptling.dev/reference/) - Complete language reference
- [Using knot.\* Libraries](scripting/using-libraries.md) - Configuration and authentication
- [Library Reference](../knot-reference/libraries.md) - knot.\* library documentation
- [Startup/Shutdown Scripts](spaces/startup-scripts.md) - Space lifecycle scripts
