---
title: MCP
description: Enable and configure knot's Model Context Protocol server and connect MCP clients.
type: Guide
tags: [ai, mcp]
weight: 10
---

The Model Context Protocol (MCP) server can be enabled on the Knot server by adding the following configuration to the `knot.toml` file:

```toml
[server.mcp]
enabled = true
```

This configuration enables the MCP server at the path `/mcp`. Notably, it does not require Knot to have access to a Large Language Model (LLM).

---

## Connecting a Client

The Knot MCP server operates over HTTP transport and is accessible at the URL: `https://<your-knot-domain.com>/mcp`

For example, if your Knot installation is hosted at `knot.getknot.dev`, the MCP server URL would be: `https://knot.getknot.dev/mcp`

### OAuth2-Supported Clients
If your client supports OAuth2, it will connect to the MCP server and allow you to log in using your standard credentials. During this process, an [API token](/docs/api-tokens/) scoped to the MCP endpoint will be generated for use.

Clients discover how to sign in from the server itself: an unauthenticated request to `/mcp` is answered with a `WWW-Authenticate` header pointing to `/.well-known/oauth-protected-resource`, and clients without a client ID register themselves at `/register`. A registered client can only receive authorization codes at the redirect URIs it registered.

### Claude
How you connect Claude depends on whether Anthropic's cloud can reach your knot server.

#### Servers on the internet: custom connector
Knot can be added to Claude as a custom connector, making its tools available in the Claude desktop app, on claude.ai and on mobile:

1. In Claude, open **Settings → Connectors** and choose **Add custom connector**.
2. Enter a name, such as `knot`, and the URL `https://<your-knot-domain.com>/mcp`.
3. Choose **Connect**, sign in to knot if asked, and select **Authorize**.

Claude connects to custom connectors from Anthropic's cloud, so the knot server must be reachable from the internet over HTTPS, with `server.url` set to its public URL.

#### Servers on a private network: desktop extension
The knot extension for the Claude desktop app runs on your computer and talks to the knot server directly, so it works with servers on a private network. It's available for macOS and Windows, and uses the connection set up with [`knot connect`](/reference/cli/knot/#knot-connect).

1. Run `knot connect` to connect to your knot server, if you haven't already.
2. Download the `.mcpb` file from the [knot Claude extension releases](https://github.com/paularlott/knot-claude-extension/releases) and open it, or drag it into **Settings → Extensions** in the Claude desktop app.
3. Choose **Install**.

The extension's settings are all optional:

| Setting | Use |
|---|---|
| Connection alias | The `knot connect` connection to use; `default` unless you set another |
| Server URL and API token | A server to use instead of a `knot connect` connection, with an [API token](/docs/api-tokens/) for it; a token with only the `mcp` scope is enough |

If you have the `knot` command installed and connected with `knot connect`, you can instead add [`knot mcp`](/reference/cli/knot/#knot-mcp) to Claude Desktop's configuration:

```json
{
  "mcpServers": {
    "knot": {
      "command": "knot",
      "args": ["mcp", "--alias", "default"]
    }
  }
}
```

### Non-OAuth2 Clients
For clients that do not support OAuth2, you will need to manually generate a new [API token](/docs/api-tokens/) via the web interface and provide it to the MCP client. Use the following format:

| Key           | Value                     |
|---------------|---------------------------|
| Authorization | Bearer `your token`       |

In both cases, the MCP client will have the same level of access to tools as the user who generated the API token.

{{< tip >}}
The web assistant may ask the browser user to approve write-capable tool calls before they run. This approval prompt is part of the web chat flow only; external MCP clients connected to `/mcp` are not prompted by Knot's browser confirmation UI.
{{< /tip >}}

---

## Finding Tools

Only knot's most used tools appear in the tool list. The rest are found on demand: a client calls `tool_search` with a few words describing the task, or with no query to list every tool, then `execute_tool` with the tool's name and arguments. The server's instructions explain this to the model when it connects.

**Example:**
```
tool_search(query="create pool") → Returns matching tools with their input schemas
execute_tool(name="create_pool", arguments={...}) → Runs the tool
```

For a client that doesn't follow the discovery pattern, send the `X-MCP-Show-All: true` header, or add `?show_all=true` to the URL, to list every tool directly. `knot mcp --show-all` does the same through the stdio proxy.

Which tools are listed and which are on demand is set per tool; see [Tool Visibility](/docs/ai/mcp-tools/#tool-visibility).

---

## Tools

The Knot MCP server exposes built-in tools for managing spaces, templates, stack definitions, stacks, files, and commands. Skills are served separately over the MCP skills extension (`skills/list`, `skills/get`), not as tools; see [Skills](../skills/). Write-capable tools require approval when called from the web assistant; read-only tools run without a confirmation. External MCP clients connected to `/mcp` are not prompted.

For the full list grouped by what each tool operates on — plus whether each is **native** or **on-demand** — see [MCP Tools](/docs/ai/mcp-tools/).

---

## Remote MCP Servers

Knot can connect to external MCP servers and use their tools alongside the built-in ones in Knot's own AI features: the web chat, the OpenAI-compatible endpoints, and `knot.mcp` in scripts. The public `/mcp` endpoint serves Knot's own tools only; external clients connect to remote servers directly.

Remote tools are namespaced with a prefix (e.g., `ai__generate-text`) to avoid conflicts with local tools.

For detailed configuration and usage, see [Remote MCP Servers](/docs/ai/mcp-remote/).
