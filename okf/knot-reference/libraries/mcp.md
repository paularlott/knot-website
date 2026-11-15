---
description: MCP tool discovery and execution across all execution environments.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/libraries/mcp/
sources:
    - resource: https://getknot.dev/reference/libraries/mcp/
status: stable
tags:
    - mcp
    - ai
    - api
    - scripting
title: knot.mcp
type: API Reference
---
# knot.mcp

The `knot.mcp` library provides MCP (Model Context Protocol) tool discovery and execution. It exposes the same flat function interface in all environments — in embedded contexts (MCP tool execution, remote/space scripts, `knot run-script`) routing through the server's internal endpoint, and in External contexts connecting to the server's `/mcp` endpoint via `knot.apiclient` config.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, plugin handlers, remote/space scripts, `knot run-script`) | Go library routes tool discovery and execution through the server's internal MCP endpoint, with per-user tool scoping applied automatically. |
| Health check scripts | Python implementation, as for external scripts: it connects to the server's `/mcp` endpoint once `knot.apiclient` has configured itself, which needs `KNOT_API_PORT` (or `KNOT_URL`/`KNOT_TOKEN`) in the space's environment; otherwise calls raise. |
| External (standalone scripts) | Python implementation. Connects to the server's `/mcp` endpoint using the `knot.apiclient` configuration. |

---

## Functions

| Function | Description |
|----------|-------------|
| `list_tools()` | Get all available MCP tools |
| `call_tool(name, arguments)` | Call an MCP tool directly (`name=` and `arguments=` may be given by keyword) |
| `tool_search(query, max_results=10)` | Search for tools by keyword; `max_results` may be positional or a keyword |
| `execute_tool(name, arguments)` | Execute a discovered tool (`name=` and `arguments=` may be given by keyword) |

---

## Usage

```python
import knot.mcp as mcp

# List all available tools
tools = mcp.list_tools()
for tool in tools:
    print(f"{tool['name']}: {tool['description']}")

# Search for tools
results = mcp.tool_search("list spaces")

# Execute a tool
spaces = mcp.execute_tool("list_spaces", {})

# Call a tool directly
response = mcp.call_tool("my_tool", {"param": "value"})
```

---

## Function Details

### list_tools()

Get a list of all available MCP tools, including tools from remote MCP servers if configured.

**Returns:** `list` - List of tool dicts with `name` and `description`. The input JSON Schema key differs by environment: embedded scripts get it as `parameters`; the external Python implementation returns the MCP tool definitions as the server sends them, with the schema under `inputSchema`. Use `tool.get("parameters") or tool.get("inputSchema")` in code meant for both.

---

### tool_search(query, max_results=10)

Search for tools by keyword.

**Parameters:**
- `query` (str): Search query
- `max_results` (int, optional): Maximum results to return (default: 10)

**Returns:** `list` - Matching tools

---

### execute_tool(name, arguments)

Execute a discovered tool.

**Parameters:**
- `name` (str): Tool name
- `arguments` (dict): Arguments to pass to the tool

**Returns:** `any` - The tool's response, automatically decoded from JSON if applicable

---

### call_tool(name, arguments)

Low-level tool execution. For most cases, use `execute_tool()` instead.

**Parameters:**
- `name` (str): Tool name
- `arguments` (dict): Arguments to pass

**Returns:** `any` - Tool response

---

## MCP Tool Development

For creating MCP tools, use `scriptling.mcp.tool` for parameter access and returning results:

```python
import scriptling.mcp.tool as tool
import knot.space as space

name = tool.get_string("name")
count = tool.get_int("count", 1)

s = space.get(name)
tool.return_object(s)
```

---

## Remote Tools

Tools from remote MCP servers have a namespace prefix:

```python
import knot.mcp as mcp

response = mcp.call_tool("ai__generate-text", {
    "prompt": "Write a hello world function",
    "max_tokens": 50
})
```
