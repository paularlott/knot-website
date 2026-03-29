---
title: Library Reference
weight: 20
---

Knot provides several libraries in the `knot.*` namespace for interacting with the platform from scripts.

---

## Available Libraries

| Library | Description |
|---------|-------------|
| [knot.apiclient](apiclient/) | Transport configuration for standalone use |
| [knot.space](space/) | Space management operations |
| [knot.ai](ai/) | AI completion functions |
| [knot.mcp](mcp/) | MCP tool interaction |
| [knot.skill](skill/) | Skills management |
| [knot.template](template/) | Template management |
| [knot.volume](volume/) | Volume management |
| [knot.user](user/) | User management |
| [knot.group](group/) | Group management |
| [knot.role](role/) | Role management |
| [knot.vars](vars/) | Variables management |
| [knot.permission](permission/) | Permission checking |

---

## Usage

Import libraries using standard Python import syntax:

```python
import knot.space as space
import knot.ai as ai
import knot.mcp as mcp

# Use the libraries
spaces = space.list()
client = ai.Client()
tools = mcp.Client().tools()
```

---

## Environment Compatibility

All `knot.*` libraries are available in all embedded environments (local, MCP, remote). `knot.ai` and `knot.mcp` are only available in embedded contexts — external scripts should use `scriptling.ai` and `scriptling.mcp` directly.

---

## Authentication

Scripts automatically authenticate using the context they're running in — no explicit token handling is needed. The `knot.apiclient` transport is pre-configured by the runtime.
