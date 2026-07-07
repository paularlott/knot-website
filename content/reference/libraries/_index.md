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
| [knot.pool](pool/) | Space pool management and scaling |
| [knot.server](server/) | Server information |
| [knot.ai](ai/) | AI completion functions |
| [knot.methods](methods/) | Register JSON-RPC methods (agent-side only) |
| [knot.methods.schema](methods-schema/) | JSON Schema builder for method params and results |
| [knot.mcp](mcp/) | MCP tool interaction |
| [knot.skill](skill/) | Skills management |
| [knot.slash_command](slash_command/) | Slash command management |
| [knot.script](script/) | Script management and execution |
| [knot.stack](stack/) | Stack definition and instance management |
| [knot.template](template/) | Template management |
| [knot.volume](volume/) | Volume management |
| [knot.user](user/) | User management |
| [knot.group](group/) | Group management |
| [knot.role](role/) | Role management |
| [knot.vars](vars/) | Variables management |
| [knot.permission](permission/) | Permission checking |
| [knot.healthcheck](healthcheck/) | Space health monitoring (health check scripts only) |
| [knot.event](event/) | Event emission (space-side) and sink accessors (server-side) |
| [knot.audit](audit/) | Audit log search and filtering |

---

## Scriptling libraries

The full `scriptling.*` library set is documented on the [Scriptling website](https://scriptling.dev/reference/libraries/), including:

- [`scriptling.net.resolve`](https://scriptling.dev/reference/libraries/scriptling/networking/resolve/) — DNS resolution for IP, SRV, and srv+http URLs
- [`scriptling.provision.file`](https://scriptling.dev/reference/libraries/scriptling/provisioning/provision-file/) — idempotent file provisioning
- [`scriptling.provision.fetch`](https://scriptling.dev/reference/libraries/scriptling/provisioning/provision-fetch/) — download files and unpack zip archives over HTTP/HTTPS

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

Each library's availability depends on where the script runs. Not every library is available in every context — most notably, MCP tool execution environments do **not** provide `knot.methods`, `knot.event.emit()`, or system access libraries. Every reference page opens with an **Execution Environment** table showing exactly where that library works.

Summary of the embedded execution contexts:

- **MCP tool execution**, **event sink scripts**, **remote/space scripts**, and **`knot run-script`** register the Go-provided `knot.apiclient` transport, so the API libraries (`knot.space`, `knot.user`, `knot.group`, `knot.role`, `knot.audit`, `knot.permission`, `knot.vars`, `knot.volume`, `knot.script`, `knot.skill`, `knot.slash_command`, `knot.server`, `knot.template`, `knot.stack`, `knot.pool`), plus `knot.ai` and `knot.mcp`, are available and authenticated automatically.
- **`knot.methods` / `knot.methods.schema`** are agent-side only: remote/space scripts and `knot run-script`. They are not available in MCP tool execution, event sink scripts, or `knot run-script` server mode.
- **`knot.event`** is context-sensitive: `emit()` runs in space-side scripts, MCP tool execution, and external standalone scripts; the payload/metadata accessors run only in event sink scripts.
- **`knot.healthcheck`** runs only in health check scripts (and `knot run-script`).
- **Health check scripts** have no `knot.apiclient` transport, so none of the API libraries are available there except `knot.healthcheck`.

For standalone scripts running outside knot (the scriptling CLI), the Python implementations resolve over HTTP via `knot.apiclient` configuration; `knot.methods`, `knot.event`, and `knot.healthcheck` have no standalone form.

---

## Authentication

Scripts automatically authenticate using the context they're running in — no explicit token handling is needed. The `knot.apiclient` transport is pre-configured by the runtime.
