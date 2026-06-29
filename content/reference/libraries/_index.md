---
title: Library Reference
weight: 30
---

Knot provides several libraries in the `knot.*` namespace for interacting with the platform from scripts.

---

## Available Libraries

| Library | Description |
|---------|-------------|
| [knot.apiclient](apiclient/) | Transport configuration for standalone use |
| [knot.space](space/) | Space management operations |
| [knot.server](server/) | Server information |
| [knot.ai](ai/) | AI completion functions |
| [knot.methods](methods/) | Register JSON-RPC methods (agent-side only) |
| [knot.methods.schema](methods-schema/) | JSON Schema builder for method params and results |
| [knot.mcp](mcp/) | MCP tool interaction |
| [knot.skill](skill/) | Skills management |
| [knot.script](script/) | Script management and execution |
| [knot.stack](stack/) | Stack definition and instance management |
| [knot.template](template/) | Template management |
| [knot.volume](volume/) | Volume management |
| [knot.user](user/) | User management |
| [knot.group](group/) | Group management |
| [knot.role](role/) | Role management |
| [knot.vars](vars/) | Variables management |
| [knot.permission](permission/) | Permission checking |
| [knot.healthcheck](healthcheck/) | Space health monitoring (agent-side only) |
| [knot.audit](audit/) | Audit log search and filtering |
| [scriptling.net.resolve](net-resolve/) | DNS resolution for IP, SRV, and srv+http URLs |
| [scriptling.provision.file](provision-file/) | Idempotent file provisioning with correct permissions |
| [scriptling.provision.fetch](provision-fetch/) | Download files and unpack zip archives over HTTP/HTTPS |

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

All `knot.*` libraries are available in all embedded environments (local, MCP, remote), except `knot.healthcheck` which is only available in agent-side health check scripts, and `knot.methods` / `knot.methods.schema` which are not available in MCP tool execution environments. `knot.ai` and `knot.mcp` are only available in embedded contexts — external scripts should use `scriptling.ai` and `scriptling.mcp` directly.

---

## Authentication

Scripts automatically authenticate using the context they're running in — no explicit token handling is needed. The `knot.apiclient` transport is pre-configured by the runtime.
