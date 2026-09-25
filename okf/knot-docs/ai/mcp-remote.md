---
description: Connect external MCP servers to knot for its own AI features (web chat, OpenAI-compatible API, scripts).
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/ai/mcp-remote/
sources:
    - resource: https://getknot.dev/docs/ai/mcp-remote/
status: stable
tags:
    - ai
    - mcp
    - networking
title: Remote MCP Servers
type: Guide
---
# Remote MCP Servers

Knot's server can connect to external MCP servers and use their tools alongside Knot's own, in the web chat, the OpenAI-compatible endpoints, and `knot.mcp` in scripts. The public `/mcp` endpoint is deliberately not part of this: it serves Knot's own tools only, so an external MCP client that wants another server's tools connects to that server directly.

---

## Where Remote Tools Are Available

### Knot's AI Features (Web Chat, OpenAI-Compatible API, Scripts)

Remote servers' tools are listed and called here, prefixed with their namespace to avoid conflicts with Knot's own tools. These consumers resolve their tools in-process: they have no way to attach to MCP servers themselves, so Knot federates on their behalf. A remote server that supports the MCP skills extension contributes its skills to the web assistant's system prompt too (namespaced like its tools), with the content readable through the chat's skill retrieval; everything else stays knot's own.

### `/mcp` (External MCP Clients)

The public endpoint serves Knot's own tools only: script tools, space methods and built-ins. Remote servers are never federated through it: the endpoint's tool list describes Knot alone, doesn't change when a remote server is added or removed, and clients connect to any other server directly.

---

## Configuration

Remote MCP servers are configured in the `knot.toml` configuration file under the `[server.mcp]` section:

```toml
[server.mcp]
enabled = true

# HTTP remote server
[[server.mcp.remote_servers]]
namespace = "ai"
url = "https://ai.example.com/mcp"
token = "your-bearer-token"
notifications = true   # accept listChanged notifications from this server

# Another HTTP server, tools discoverable on-demand
[[server.mcp.remote_servers]]
namespace = "data"
url = "https://data.example.com/mcp"
token = "your-bearer-token"
tool_visibility = "on-demand"

# stdio remote server: a local executable launched as a subprocess
[[server.mcp.remote_servers]]
namespace = "fs"
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "/data"]
env = ["FS_ROOT=/data", "LOG_LEVEL=debug"]  # extra KEY=VALUE vars (merged on top of the inherited environment)
```

Remote servers can be either **HTTP** (`url` + `token`) or **stdio**
(`command` + `args`): a local executable that Knot launches as a subprocess and
talks to over stdin/stdout. stdio servers need no token.

### Configuration Fields

| Field | Description |
|-------|-------------|
| `namespace` | The namespace prefix for tools from this server (e.g., tools appear as `ai__generate-text` in the chat and scripts) |
| `url` | The full URL of a remote **HTTP** MCP server endpoint (omit for stdio) |
| `token` | Bearer token for **HTTP** authentication (omit for stdio) |
| `command` | For **stdio** servers: the executable to launch as a subprocess (omit for HTTP) |
| `args` | For **stdio** servers: command-line arguments (array of strings) |
| `env` | Optional, **stdio** only. Extra `KEY=value` environment variables for the subprocess (array of strings). These are merged on top of the inherited environment, so `PATH`, `HOME`, etc. are preserved. |
| `tool_visibility` | Optional (default: `native`). Controls how tools are exposed: |
| | `native` - Full tool definitions sent immediately (default) |
| | `on-demand` - Tools discovered on-demand via `tool_search`, reduces context usage |
| | `discoverable` - Alias for `on-demand` |
| `hidden` | Optional (default: `false`). When `true`, the server's tools are callable but not shown in tool listings — see [Hidden Tools](#hidden-tools). |
| `notifications` | Optional (default: `false`). When `true`, Knot accepts `listChanged` notifications from this server and propagates them to its own clients, so tool changes on the remote are reflected automatically. stdio servers propagate automatically regardless. |

---

## How It Works

When the Knot server starts, it:

1. Reads the remote server configuration
2. Creates a Bearer token authenticator for each remote server
3. Registers each remote server with the internal MCP server
4. Makes the remote tools available to Knot's own AI features (the public `/mcp` endpoint is not included)

### Tool Namespacing

Tools from remote servers are prefixed with their namespace to avoid conflicts:

- **Local tools**: `list_spaces`, `list_templates`, etc.
- **Remote tools**: `ai__generate-text`, `data__query`, etc.

The prefix appears wherever remote tools surface: the web chat's tool list and `knot.mcp` in scripts. External MCP clients never see it, because they never see remote tools through Knot.

### Hidden Tools

Remote servers can be configured with `hidden = true` to make their tools callable but not visible in tool listings. This is useful for:

- **Internal/utility tools**: Tools that should only be called from scripts, not directly by AI
- **Reducing context**: Keeping tool lists concise while still allowing script access
- **Security**: Hiding sensitive internal APIs from external visibility

Hidden tools can still be called using `knot.mcp.call_tool()` in scripts, but won't appear in `knot.mcp.list_tools()` responses.

### Authentication

Remote servers use Bearer token authentication. The token is configured in the TOML file and sent with each request to the remote server.

---

## Live Tool Updates (Notifications)

Knot's MCP server advertises `listChanged` support and pushes notifications to
connected clients when its tool set changes, so MCP clients (Claude Desktop, VS
Code, etc.) refresh their cached tool list automatically. This happens in two
ways:

1. **Knot's own tools change** — when a user's scripts are created, updated, or
   deleted, Knot emits `notifications/tools/listChanged`. (This is a broadcast:
   each connected client re-fetches and receives its own, permission-scoped tool
   list.)
2. **A remote server's tools change** — set `notifications = true` on a remote
   server and Knot accepts its `listChanged` events and refreshes its merged
   tool cache, so the chat and scripts see fresh tools. stdio remote servers
   propagate automatically (no flag needed); HTTP remote servers need the flag
   and must themselves support SSE push.

On the client side, an SSE connection to `/mcp` (`Accept: text/event-stream`)
receives these notifications; clients that don't open the stream simply poll
as before.

---

## Usage Examples

### In Scripts

```python
import knot.mcp

# List all available tools (including remote ones)
tools = knot.mcp.list_tools()
for tool in tools:
    print(f"Tool: {tool['name']}")
    # Tools will include both local (list_spaces) and remote (ai__generate-text)

# Call a remote tool directly
response = knot.mcp.call_tool("ai__generate-text", {
    "prompt": "Write a Python function",
    "max_tokens": 100
})
print(response)

# Call a hidden tool (not listed but callable)
response = knot.mcp.call_tool("internal__process-data", {
    "data_id": "12345"
})
print(response)

# Or let AI discover and use tools automatically
import knot.ai as ai
client = ai.Client()
model = ai.get_default_model()
messages = [
    {"role": "user", "content": "Generate a Python function and save it to a file in my dev space"}
]
response = client.completion(model, messages)
# AI will automatically use both remote (ai__generate-text) and local (write_file) tools
```

### In MCP Clients

When connecting to Knot's MCP server from external clients (like Claude Desktop or VS Code extensions), use the `/mcp` endpoint:

```json
{
  "mcpServers": {
    "knot": {
      "url": "https://knot.example.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_API_TOKEN"
      }
    }
  }
}
```

The endpoint serves Knot's own tools through standard MCP methods:

- `tools/list` - Lists Knot's tools with full schemas
- `tools/call` - Executes a tool directly

Tools from remote servers are not available here; if your client needs them, add a second server entry pointing at the remote server directly. Knot's own AI features (web chat, scripts) continue to see remote tools with their namespace prefix.

---

## Security Considerations

1. **Token Security**: Store bearer tokens securely in the configuration file with appropriate file permissions
2. **Network Security**: Ensure remote servers use HTTPS to protect tokens in transit
3. **Access Control**: The Knot server doesn't enforce permissions on remote tools - the remote server is responsible for authorization

---

## Troubleshooting

### Common Issues

1. **Connection Failed**: Check that the remote server URL is accessible and correct
2. **Authentication Failed**: Verify the bearer token is valid and not expired
3. **Tools Not Appearing**: Check the remote server is running and properly configured

### Debug Logs

Enable debug logging to see information about remote server connections:

```bash
knot server --log-level debug
```

You'll see logs like:

- `Registering remote MCP server: ai-tools (namespace: ai)`
- `Successfully connected to remote MCP server: ai-tools`
- `Failed to register remote MCP server: data-services - authentication failed`
