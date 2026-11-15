---
title: knot.mcp_server
description: Manage remote MCP servers whose tools knot exposes under a namespace.
type: API Reference
tags: [mcp, ai, api, scripting]
weight: 95
---

The `knot.mcp_server` library manages [remote MCP servers](/docs/ai/mcp-remote/): other MCP servers, reached over HTTP(S) or started as a stdio command, whose tools knot exposes to the user who added them under the server's namespace. Calling those tools is [`knot.mcp`](../mcp/)'s job; this library manages the server records. Creating, changing and deleting servers needs the **Manage MCP Servers** permission.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, plugin handlers, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Only when the space's environment sets `KNOT_API_PORT` or `KNOT_URL`/`KNOT_TOKEN`: there is no built-in transport, so the Python `knot.apiclient` configures itself from the agent (as the space owner) or those variables, and calls raise otherwise. See [Environment Compatibility](/reference/libraries/#environment-compatibility). |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `list(user_id=None)` | List remote MCP servers |
| `get(namespace_or_id)` | Get a server, without its token values |
| `create(namespace, url="", command="", ...)` | Add a server; returns its ID |
| `update(namespace_or_id, ...)` | Update a server; only the arguments given change |
| `delete(namespace_or_id)` | Delete a server |
| `tools(namespace_or_id)` | Connect to a server and list its tools |
| `set_tool_enabled(namespace_or_id, tool_name, enabled)` | Switch one of a server's tools on or off |
| `protocol_version(namespace_or_id)` | The MCP protocol version negotiated with a server |

Servers are found by namespace (among your own) or ID.

---

### list(user_id=None)

List remote MCP servers, sorted by namespace.

**Parameters:**
- `user_id` (string, optional): List another user's servers (needs **Manage MCP Servers**). Default: your own.

**Returns:** `list` of dicts, each containing:
- `id` (string), `user_id` (string)
- `namespace` (string): Prefix the server's tools are exposed under
- `url` (string): HTTP(S) endpoint, empty for a stdio server
- `command` (string), `args` (list), `env` (list of `"KEY=value"`): How a stdio server is started
- `enabled` (bool): Whether knot connects to the server
- `tool_visibility` (string): `"native"` (tools listed in tools/list) or `"discoverable"` (found only through tool_search)
- `disabled_tools` (list): Tool names switched off
- `remote_search` (bool): Whether tool_search queries are forwarded to the server

---

### get(namespace_or_id)

Get a remote MCP server. Token values are never returned.

**Returns:** `dict` - The fields `list()` returns, plus `auth_type` (`""`, `"bearer"` or `"oauth2"`), `has_token`, `oauth_client_id`, `oauth_token_url` and `has_oauth_tokens`.

---

### create(namespace, url="", command="", args=None, env=None, auth_type="", token="", oauth_client_id="", oauth_token_url="", oauth_access_token="", oauth_refresh_token="", enabled=True, tool_visibility="native", remote_search=False)

Add a remote MCP server for the current user. Give `url` for an HTTP(S) server, or `command` (with `args` and `env`) for a stdio server.

**Parameters:**
- `namespace` (string): Prefix for the server's tools; unique among your servers and must not contain `__`
- `url` (string): HTTP(S) endpoint
- `command` (string), `args` (list), `env` (list of `"KEY=value"`): stdio server
- `auth_type` (string): `""` (none), `"bearer"` (with `token`) or `"oauth2"` (with the `oauth_*` arguments)
- `enabled` (bool): Whether knot connects to the server (default `True`)
- `tool_visibility` (string): `"native"` (default) or `"discoverable"`
- `remote_search` (bool): Forward tool_search queries to the server

**Returns:** `string` - The new server's ID. Raises if neither `url` nor `command` is given, or the namespace is taken or invalid.

---

### update(namespace_or_id, namespace=None, url=None, command=None, args=None, env=None, auth_type=None, token=None, oauth_client_id=None, oauth_token_url=None, oauth_access_token=None, oauth_refresh_token=None, enabled=None, tool_visibility=None, remote_search=None)

Update a remote MCP server. Only the arguments given change — `namespace` renames it — and stored tokens are kept unless new ones are given.

**Returns:** `bool` - `True` on success

---

### delete(namespace_or_id)

**Returns:** `bool` - `True` on success

---

### tools(namespace_or_id)

Connect to the server now and list its tools.

**Returns:** `list` of dicts with `name` (without the namespace prefix), `description`, `enabled` and `is_app` (an MCP Apps tool, with a linked `ui://` resource). Raises with the reason when the server cannot be reached.

---

### set_tool_enabled(namespace_or_id, tool_name, enabled)

Switch one of the server's tools on or off; a tool switched off is not offered.

**Returns:** `bool` - `True` on success

---

### protocol_version(namespace_or_id)

**Returns:** `string` - The MCP protocol version negotiated with the server, e.g. `"2025-06-18"`; empty when it cannot be reached.

---

## Examples

```python
import knot.mcp_server as mcp_server

mcp_server.create("github", url="https://api.githubcopilot.com/mcp/",
                  auth_type="bearer", token="ghp_...")

for tool in mcp_server.tools("github"):
    if tool["name"].startswith("delete_"):
        mcp_server.set_tool_enabled("github", tool["name"], False)
```
