---
title: MCP Tools
weight: 12
---

The **knot** MCP server exposes a set of built-in tools that AI assistants and MCP clients can use to manage spaces, templates, stack definitions, and the files and commands inside running spaces. The exact tools available to a given caller depend on the user's permissions.

Write-capable tools (create, update, delete, start, stop, share, transfer, run, write) require approval when called from the **knot** web assistant. Read-only tools run without a confirmation prompt. External MCP clients connected to `/mcp` are not prompted.

---

## Tool Visibility

Each tool is either **native** or **on-demand**. This controls how it appears to MCP clients:

| Visibility | Behaviour |
|------------|-----------|
| **Native** | Always present in `tools/list` and can be called directly by name. |
| **On-demand** | Hidden from the default `tools/list` to keep context usage low. Discover with `tool_search(query=...)` and run with `execute_tool(name=..., arguments=...)`. To pre-load all on-demand tools into `tools/list` instead, set `native_tools = true` under `[server.mcp]` in `knot.toml`. |

See [Tool Modes](../mcp/#tool-modes) for configuration details.

---

## Spaces

| Tool | Description | Visibility |
|------|-------------|------------|
| `list_spaces` | List all spaces for the current user, including status and sharing details. | Native |
| `get_space` | Retrieve detailed space information, including configuration and status. | Native |
| `create_space` | Create a new development space, optionally with custom fields and start-on-create. | Native |
| `update_space` | Update properties of an existing space (name, description, shell, custom fields). | On-demand |
| `delete_space` | Permanently delete a space and all its data. | On-demand |
| `start_space` | Start a space. | Native |
| `stop_space` | Stop a space. | Native |
| `restart_space` | Restart a space. | On-demand |

---

## Templates

Templates are read-only via MCP — authoring and editing happens through the **knot** web UI or CLI. `list_templates` returns active templates only, including each template's custom field definitions (name and description) so callers have what they need to set custom fields when creating a space.

| Tool | Description | Visibility |
|------|-------------|------------|
| `list_templates` | List active space templates, including their custom field definitions. | On-demand |

---

## Stack Definitions

Stack definitions are blueprints that describe a set of components (template bindings) and the dependencies between them. They are instantiated into running stacks via `create_stack`. Definitions are authored through the **knot** web UI or CLI; MCP exposes read access so AI assistants can discover what's available to instantiate.

| Tool | Description | Visibility |
|------|-------------|------------|
| `list_stack_definitions` | List stack definitions available to the current user, including their components. | On-demand |

---

## Stacks

A stack is a deployed instance — a group of spaces that share a stack name, typically created from a stack definition.

| Tool | Description | Visibility |
|------|-------------|------------|
| `list_stacks` | List stack instances by grouping spaces with the same stack name. | On-demand |
| `create_stack` | Instantiate a stack from a stack definition: creates the spaces, wires up dependencies, and applies port forwards. | On-demand |
| `start_stack` | Start all spaces in a stack in dependency order. | On-demand |
| `stop_stack` | Stop all spaces in a stack in reverse dependency order. | On-demand |
| `restart_stack` | Restart all spaces in a stack. | On-demand |
| `delete_stack` | Delete all stopped spaces in a stack. Running spaces must be stopped first. | On-demand |

---

## Files

Operations on files inside a running space.

| Tool | Description | Visibility |
|------|-------------|------------|
| `read_file` | Read the contents of a file from a running space. | Native |
| `write_file` | Write content to a file in a running space. | Native |

---

## Commands

Operations that execute inside a running space. `list_scripts` is the discovery companion to `run_script` — call it first to see which named scripts are available.

| Tool | Description | Visibility |
|------|-------------|------------|
| `list_scripts` | List active scripts available to run via `run_script`. Filters to the current zone and the caller's groups. | On-demand |
| `run_command` | Execute a command in a running space and return the results. | Native |
| `run_script` | Execute a named script in a running space. | Native |

---

## Skills

Skills are markdown knowledge documents that give AI assistants context and procedures (see [Skills](../skills/)).

| Tool | Description | Visibility |
|------|-------------|------------|
| `get_skill` | Retrieve a skill by exact name, search by keyword, or list active skills. | On-demand |

---

## Tool Discovery

These tools are provided by the MCP server itself to support the on-demand discovery pattern. They are available on the discovery endpoint (`/mcp/discovery`).

| Tool | Description |
|------|-------------|
| `tool_search` | Search for available tools by keyword or description. Returns matching tool names and schemas. |
| `execute_tool` | Execute a tool that was found via `tool_search`. Takes the tool name and an arguments object. |

---

## What's Next

- [MCP](../mcp/) - Enabling and configuring the MCP server
- [Remote MCP Servers](../mcp-remote/) - Connecting external MCP servers
- [Skills](../skills/) - Authoring knowledge content for AI assistants
