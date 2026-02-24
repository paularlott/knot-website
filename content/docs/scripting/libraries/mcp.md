---
title: knot.mcp
weight: 30
---

The `knot.mcp` library provides MCP (Model Context Protocol) functionality for scripts, including tool discovery and execution.

---

## Functions

| Function | Description |
|----------|-------------|
| `list_tools()` | Get a list of all available MCP tools |
| `call_tool(name, arguments)` | Call an MCP tool directly |
| `tool_search(query, max_results=10)` | Search for tools by keyword |
| `execute_tool(name, arguments)` | Execute a discovered tool |

---

## Usage

```python
import knot.mcp as mcp

# List all available tools
tools = mcp.list_tools()
for tool in tools:
    print(f"Tool: {tool['name']} - {tool['description']}")

# Search for space-related tools
results = mcp.tool_search("list spaces")
print(results)

# Execute a tool
spaces = mcp.execute_tool("list_spaces", {})
print(spaces)
```

---

## Function Details

### list_tools()

Get a list of all available MCP tools, including tools from remote MCP servers if configured.

**Returns:** `list` - List of tool objects with `name`, `description`, and `parameters` (JSON Schema).

---

### tool_search(query, max_results=10)

Search for tools by keyword.

**Parameters:**
- `query` (string): Search query
- `max_results` (int, optional): Maximum results to return (default: 10)

**Returns:** `list` - Matching tools

---

### execute_tool(name, arguments)

Execute a discovered tool.

**Parameters:**
- `name` (string): Tool name
- `arguments` (dict): Arguments to pass to the tool

**Returns:** `any` - The tool's response, automatically decoded from JSON if applicable.

---

### call_tool(name, arguments)

Low-level tool execution. For most cases, use `execute_tool()` instead.

**Parameters:**
- `name` (string): Tool name
- `arguments` (dict): Arguments to pass

**Returns:** `any` - Tool response

---

## MCP Tool Development

For creating MCP tools, use `scriptling.mcp.tool` for portable parameter access:

```python
import scriptling.mcp.tool as tool
import knot.space

# Get parameters
name = tool.get_string("name")
count = tool.get_int("count", 1)

# Use knot libraries
space = knot.space.get(name)

# Return result
tool.return_object(space)
```

---

## Remote Tools

Tools from remote MCP servers have a namespace prefix:

```python
import knot.mcp as mcp

# Call a remote tool
response = mcp.call_tool("ai.generate-text", {
    "prompt": "Write a hello world function",
    "max_tokens": 50
})
print(response)
```
