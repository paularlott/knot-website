---
title: MCP
weight: 10
---

The Model Context Protocol (MCP) server can be enabled on the **knot** server by adding the following configuration to the `knot.toml` file:

```toml
[server.mcp]
enabled = true
```

This configuration enables the MCP server at the path `/mcp`. Notably, it does not require **knot** to have access to a Large Language Model (LLM).

---

## Connecting a Client

The **knot** MCP server operates over HTTP transport and is accessible at the URL: `https://<your-knot-domain.com>/mcp`

For example, if your **knot** installation is hosted at `knot.getknot.dev`, the MCP server URL would be: `https://knot.getknot.dev/mcp`

### OAuth2-Supported Clients
If your client supports OAuth2, it will connect to the MCP server and allow you to log in using your standard credentials. During this process, an [API token](../../api-tokens/) will be generated for use.

### Non-OAuth2 Clients
For clients that do not support OAuth2, you will need to manually generate a new [API token](../../api-tokens/) via the web interface and provide it to the MCP client. Use the following format:

| Key           | Value                     |
|---------------|---------------------------|
| Authorization | Bearer `your token`       |

In both cases, the MCP client will have the same level of access to tools as the user who generated the API token.

{{< tip >}}
The web assistant may ask the browser user to approve write-capable tool calls before they run. This approval prompt is part of the web chat flow only; external MCP clients connected to `/mcp` are not prompted by Knot's browser confirmation UI.
{{< /tip >}}

---

## Tool Modes

Knot's MCP server supports two different tool modes, configured with the `native_tools` setting in your `knot.toml`:

### Tool Discovery Mode (Default)

In tool discovery mode, tools are discovered on-demand to minimize context usage. This is efficient for AI assistants that need to manage their token usage.

**Workflow:**
1. Use `tool_search(query="<operation>")` to find the appropriate tool
2. Use `execute_tool(name="<tool_name>", arguments={...})` to execute the tool

**Example:**
```
tool_search("list spaces") → Returns tool information
execute_tool("list_spaces", {}) → Executes the tool
```

**Benefits:**
- Dynamic tool availability based on user permissions
- Reduced memory footprint and context usage
- Permission-based filtering
- Request-scoped authentication

### Native Tools Mode

In native tools mode, all tools are pre-loaded and directly available without discovery. This is simpler for clients that don't support the discovery pattern.

**Configuration:**
```toml
[server.mcp]
enabled = true
native_tools = true
```

**Workflow:**
- All tools are available directly in the tool list
- Use tools by name with their required arguments
- No discovery pattern needed

**Example:**
```
list_spaces() → Direct tool call
create_space({...}) → Direct tool call
```

---

## Tools

The **knot** MCP server exposes built-in tools for managing spaces, templates, stack definitions, stacks, files, commands, and skills. Write-capable tools require approval when called from the web assistant; read-only tools run without a confirmation. External MCP clients connected to `/mcp` are not prompted.

For the full list grouped by what each tool operates on — plus whether each is **native** or **on-demand** — see [MCP Tools](mcp-tools/).

---

## Remote MCP Servers

Knot can connect to external MCP servers and expose their tools alongside the built-in tools. This allows you to create a unified interface for AI assistants to access tools from multiple sources.

Remote tools are namespaced with a prefix (e.g., `ai.generate-text`) to avoid conflicts with local tools.

For detailed configuration and usage, see [Remote MCP Servers](mcp-remote/).
