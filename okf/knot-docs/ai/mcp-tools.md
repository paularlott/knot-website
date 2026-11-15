---
description: Built-in MCP tools for managing spaces, templates, stacks, files, and commands in knot.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/ai/mcp-tools/
sources:
    - resource: https://getknot.dev/docs/ai/mcp-tools/
status: stable
tags:
    - ai
    - mcp
title: MCP Tools
type: Guide
---
# MCP Tools

The Knot MCP server exposes a set of built-in tools that AI assistants and MCP clients can use to manage spaces, templates, stack definitions, and the files and commands inside running spaces. The exact tools available to a given caller depend on the user's permissions. Plugins can expose further tools — see [Plugins → MCP Tools](../plugins/writing-plugins/mcp-tools.md).

In the Knot web assistant, every tool call shows a confirmation card before it runs, read-only tools included, unless the user chose **Always Allow** for that tool. Write-mode `run_script` runs are confirmed every time, with no **Always Allow**. Tools that change or remove things (such as `delete_space`, `stop_space`, `update_space`, `restart_space`, `write_file`, `edit_file`, `run_command`, `run_space_script`, `run_script`, the stop, restart and delete stack and pool tools, `create_template` and `create_pool`) are marked as requiring approval: they are published to MCP clients connected to `/mcp` as destructive, so clients that honour the hint, such as Claude Desktop and Claude Code, ask before calling them. Whether an external client asks is up to the client. The same tools are published for the model only (`_meta.ui.visibility` `["model"]`), so an MCP Apps view shown in the web assistant cannot call them.

---

## Tool Visibility

Each tool is either **native** or **on-demand**. This controls how it appears to MCP clients:

| Visibility | Behaviour |
|------------|-----------|
| **Native** | Always present in `tools/list` and can be called directly by name. |
| **On-demand** | Hidden from the default `tools/list` to keep context usage low. Discover with `tool_search(query=...)` and run with `execute_tool(name=..., arguments=...)`. To list every tool directly instead, send the `X-MCP-Show-All: true` header or use `knot mcp --show-all`. |

See [Finding Tools](mcp.md#finding-tools) for how clients use on-demand tools.

To remove built-in tools, list their names in `disable_builtin_tools` under `[server.mcp]` (flag `--mcp-disable-builtin-tools`, environment variable `KNOT_MCP_DISABLE_BUILTIN_TOOLS`):

```toml
[server.mcp]
disable_builtin_tools = ["run_command", "delete_space"]
```

To replace the built-in set entirely, point `server.mcp_tools_path` at a directory of tool definitions; knot then loads tools from that directory instead of its own.

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
| `restart_space` | Restart a space. | Native |

---

## Templates

`list_templates` returns active templates only, including each template's custom field definitions (name and description) so callers have what they need to set custom fields when creating a space. `create_template` builds a template from a simplified, wizard-style spec — the AI provides an image, environment variables, ports, resources, and feature toggles, and knot writes the native Nomad HCL or container YAML for it (the same model as the UI [spec wizard](../configuration/spec-wizard.md)). Full template editing — health checks, schedules, advanced spec features — still happens through the Knot web UI or CLI.

| Tool | Description | Visibility |
|------|-------------|------------|
| `list_templates` | List active space templates, including their custom field definitions. | On-demand |
| `get_template` | Get one template's full custom field definitions (names, types, required flags, defaults and valid option values), to see exactly what to send when creating a space. | On-demand |
| `create_template` | Create a space template from a container image using a simplified spec (image, env vars, ports, memory, CPU, features); knot builds the native spec. | On-demand |

---

## Stack Definitions

Stack definitions (called **stack templates** in the web UI) are blueprints that describe a set of components (template bindings) and the dependencies between them. They are instantiated into running stacks via `create_stack`. Definitions are authored through the Knot web UI or CLI; MCP exposes read access so AI assistants can discover what's available to instantiate.

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
| `delete_stack` | Delete all spaces in a stack. Running spaces must be stopped first; the server checks every space before deleting any, so the call is all-or-nothing. | On-demand |

---

## Files

Operations on files inside a running space. Searches run in the space's agent, so file contents don't leave the space.

| Tool | Description | Visibility |
|------|-------------|------------|
| `read_file` | Read a file from a running space, optionally a 1-based line range. | Native |
| `write_file` | Write content to a file in a running space: overwrite (the default), append or prepend. | Native |
| `edit_file` | Replace one occurrence of a string in a file; fails unless the search text appears exactly once. | On-demand |
| `find` | Find files and directories by name, type or size; recursive by default. | On-demand |
| `grep` | Search file contents with a regex or literal pattern, returning matching lines with paths and line numbers. | On-demand |
| `sed_extract` | Extract regex capture groups from a file, or files under a directory. Read-only. | On-demand |
| `sed_replace` | Replace every literal occurrence of a string in a file, or files under a directory. | On-demand |
| `sed_replace_pattern` | Replace every regex match in a file, or files under a directory; the replacement can reference capture groups as `${1}` or `${name}`. | On-demand |

---

## Commands

Operations that execute inside a running space. `list_scripts` is the discovery companion to `run_space_script` — call it first to see which named scripts are available.

| Tool | Description | Visibility |
|------|-------------|------------|
| `list_scripts` | List active scripts available to run via `run_space_script`. Filters to the current zone and the caller's groups. | On-demand |
| `run_command` | Execute a command in a running space. Returns its `output`, `success` and `exit_code`, plus `error` when it fails; a failed command's output is returned too. Each of `arguments` reaches the command unchanged. | Native |
| `run_space_script` | Execute a named script stored in knot in a running space. Called `run_script` before this release. | Native |

---

## AI-Written Scripts

For questions no single tool answers — totals, rankings, comparisons — and for changes that span many items, the assistant can write a short [scriptling](https://scriptling.dev/) script and run it on the server against the knot API, using the [`knot.*` libraries](../../knot-reference/libraries.md). Both tools are offered only to users whose role has the **Run AI Scripts** permission (and who may execute scripts, like the other built-in tools). The Admin role does not include it — an administrator's scripts could change anything on the server — so create a role with it and give that role to the users who should have it, administrators included.

| Tool | Description | Visibility |
|------|-------------|------------|
| `script_docs` | The guide to writing scripts (rules, limits, how to return an answer, worked examples), or the functions of named libraries (`space`, `space, pool`). | Native |
| `run_script` | Run a script the assistant wrote. Takes `code`, a one-sentence `purpose` and `mode`: exactly `read` (the default) or `write`; any other value, such as `WRITE`, is refused. Returns `ok`, `output`, `result`, `error`, `truncated`, `note`, `calls`, `mode` and `duration_ms`. | Native |

A script runs **as the user**, through the API, so it can see and change only what the user's own permissions allow. On top of that:

- **Read mode** (the default) can only make `GET` requests. **Write mode** can also create, change, start, stop and delete, and needs the user's approval for every run. The web assistant asks before every write-mode run and shows the code, with no **Always Allow** (read-mode runs can be always-allowed), and since `run_script` is marked destructive, MCP clients such as Claude Desktop and Claude Code ask before calling it. Write mode is refused where no one can be asked — the OpenAI-compatible endpoints, scripts calling `knot.mcp`, and calls made from inside another tool or API request — and to MCP connections signed in with an API token limited to scopes such as `mcp`. A write-mode script can reach far more of the API than those scopes grant, so such connections get read mode only; use an unscoped API token or the web assistant for write mode. OAuth connections (such as a Claude custom connector) can use write mode: the person signed in through the connector, and the client asks before each write-mode run.
- Some calls are refused in either mode:
  - API tokens, sign-in, sessions and passkeys, linked users and sign-in providers, SSH keys, and the secret routes (`/api/secrets`, personal secrets under `/api/users/{user}/secrets`, the 1Password token). Other paths are not refused for naming a secret: a space called `secret-x` or a file key `docs/secret-plan.md` is fine.
  - Backups and restores; role, permission and group changes; creating, changing or deleting users.
  - MCP server configuration (`/api/mcp-servers`), the assistant's own endpoints (`/api/chat`), event streams (`GET /api/events`) and streamed script runs (`execute-script-stream`).
  - Anything that would store or run code outside the script's guard: stored scripts (`/api/scripts`, so `knot.script` can list and read scripts but `create`, `update` and `delete` always fail), changing space jobs (`PUT /api/spaces/{space}/jobs`), creating or changing script event sinks, running the script's own code in a space (`execute-script` with `content`; running an existing script the user may run, by name or id, is allowed), and plugin field handlers (`/api/plugins/field-handlers/{id}`).
  - Anything outside `/api/...`. The space port, tunnel and port-forward functions and `jobs.run` use `/space-io/` streams, so they are refused in AI scripts. `stack.create` with a definition that has port forwards creates the spaces and then fails on the port forwards, leaving a partial stack, so the script guide tells the assistant not to use it for such stacks.
- Paths must be plain. Before the `?`, a `;`, a backslash, `.` or `..` segments, or an encoded `#`, `;`, `%`, slash, backslash or NUL is refused; query values may be encoded freely (the `knot.files` functions send `delimiter=%2F`). A `#` is refused anywhere.
- Credentials in API responses are redacted to `[redacted]`: fields named `service_password`, `ssh_private_key`, `totp_secret`, `password`, `token`, `access_token`, `refresh_token`, `oauth_access_token`, `oauth_refresh_token`, `client_secret`, `secret` or `private_key` at any depth; the values (not the names) of every `headers` object, such as an event sink's webhook headers; the user name and password of any URL in a field named `url` or ending `_url`; and, of a webhook's URL, the query values and every path segment after the first (Slack's `/services/…`, Discord's `/api/webhooks/…`), keeping the scheme and host. Nothing else is redacted.
- A script can write an object back with redacted values in it: in a `PUT` to the path it was read from, each `[redacted]` value that is exactly what was read at the same place is replaced with the stored value, so `event_sink.update(sink, active=False)` keeps the webhook's URL, headers and secret. A placeholder anywhere else is refused, as is a `PUT` that keeps redacted values while changing a URL, since the stored credentials would go to the new address.
- Request bodies are bounded before they are built: at most 16 MB of JSON, 64 KB of headers and 1 MB of query parameters, a value counting once for every place it appears.
- Scripts have no network, file system, process, AI or MCP access, and cannot import the user's own library scripts or plugin code. Besides the `knot.*` libraries and the standard modules, the `yaml`, `toml`, `scriptling.similarity` and `scriptling.template.text` libraries are available.
- Each run is limited to:
  - 60 seconds; a call still waiting at the limit (a command, script, file operation or method call in a space, say) is abandoned.
  - 500 API calls; each call in a batch sent to `/api/methods/call` counts.
  - 256 MB of memory for the script's values, and 8 MB for any single string, bytes value or list.
  - 16 MB for one API response (file reads included) and 8 MB for one upload.
  - 50,000 bytes of printed output, which is cut off beyond that (`truncated` is set).
  - 50,000 bytes for the JSON of `result`. A larger `result` is not returned: the run fails with `ok: false` and an error saying so.
  - 50,000 bytes of error text.
- A user may have 2 runs going at once, and the server 8; a run over either limit is refused before it starts, with an error telling the assistant to try again.
- Every run is recorded in the audit log as **AI Script Run**, with the mode, purpose, outcome, call count, error and code (purpose, code and error capped). A run refused before it started is recorded too, with the reason: a malformed request (such as mode `WRITE` or no code), a write-mode run no one could approve, or a run over the concurrency limits.

---

## Skills

Skills are markdown knowledge documents that give AI assistants context and procedures (see [Skills](skills.md)).

Skills are not exposed as a tool: they are served over the MCP skills extension, `skills/list` and `skills/get`, with each skill's content readable via `resources/read` on its `skill://` URI.

---

## Pools

Pools keep a target number of identical spaces running from a template. See [Space Pools](../spaces/pools.md) for the full lifecycle and port routing details.

| Tool | Description | Visibility |
|------|-------------|------------|
| `list_pools` | List pools with utilization, lease settings and members, or get one pool by name. | Discovery |
| `create_pool` | Create a pool from a template with a desired space count, optional startup script, optional start-on-create, optional member leases (`lease_max_time`, `lease_max_extensions`), and custom field values for every member. | Discovery |
| `delete_pool` | Delete a stopped pool and all its member spaces. | Discovery |
| `start_pool` | Start a stopped pool: starts all member spaces and creates new ones if needed. | Discovery |
| `stop_pool` | Stop a running pool: stops all member spaces without deleting them. | Discovery |
| `set_pool_size` | Change the desired number of spaces in a pool. The sweep loop handles scaling. | Discovery |
| `acquire_pool_member` | Check out a member of a lease-enabled pool for exclusive use, optionally for a set `time` and waiting up to `wait` for a free member. Returns the lease with the held space's name and ID. | Discovery |
| `extend_pool_lease` | Extend the lease held on a pool member; limited by the pool's maximum number of extensions. | Discovery |
| `release_pool_member` | Release a held pool member back to the pool, or with `destroy` delete it so a fresh replacement is created. | Discovery |
| `list_pool_leases` | List the leases held on a pool's members, active and draining. | Discovery |

---

## Tool Discovery

These tools are provided by the MCP server itself to support the on-demand discovery pattern. They are available on the discovery endpoint (`/mcp/discovery`).

| Tool | Description |
|------|-------------|
| `tool_search` | Search for available tools by keyword or description. Returns matching tool names and schemas. |
| `execute_tool` | Execute a tool that was found via `tool_search`. Takes the tool name and an arguments object. |

---

## What's Next

- [MCP](mcp.md) - Enabling and configuring the MCP server
- [Remote MCP Servers](mcp-remote.md) - Connecting external MCP servers
- [Skills](skills.md) - Authoring knowledge content for AI assistants
