---
title: Library Reference
weight: 20
---

Knot provides several libraries in the `knot.*` namespace for interacting with the platform from scripts.

---

## Available Libraries

| Library | Description |
|---------|-------------|
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
tools = mcp.list_tools()
```

---

## Environment Compatibility

All knot.* libraries are available in all environments, but the implementation differs:

| Library | Local | MCP | Remote |
|---------|-------|-----|--------|
| knot.space | API | Internal API | API |
| knot.ai | API | MCP Server | API |
| knot.mcp | API Tools | Special | API Tools |
| knot.skill | API | API | API |
| knot.template | API | API | API |
| knot.volume | API | API | API |
| knot.user | API | API | API |
| knot.group | API | API | API |
| knot.role | API | API | API |
| knot.vars | API | API | API |
| knot.permission | API | API | API |

- **API**: Uses HTTP API calls to the server
- **Internal**: Uses internal Go function calls (no network)
- **MCP Server**: Connects directly to the upstream AI provider
- **Special**: Has access to MCP tool parameters and context

---

## Authentication

Scripts automatically authenticate using the context they're running in:

- **Local**: Uses the configured API token from `~/.knot/config`
- **Remote**: Uses the space's agent token
- **MCP**: Uses the internal context (no explicit token needed)
