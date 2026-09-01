---
description: Knot's knot.* namespace libraries for interacting with the platform from scripts.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/libraries/
sources:
    - resource: https://getknot.dev/reference/libraries/
status: stable
tags:
    - api
    - scripting
title: Library Reference
type: Overview
---
# Library Reference

Knot provides several libraries in the `knot.*` namespace for interacting with the platform from scripts.

---

## Available Libraries

| Library | Description |
|---------|-------------|
| [knot.apiclient](libraries/apiclient.md) | Transport configuration for standalone use |
| [knot.space](libraries/space.md) | Space management operations |
| [knot.pool](libraries/pool.md) | Space pool management and scaling |
| [knot.jobs](libraries/jobs.md) | Scheduled job management for spaces |
| [knot.server](libraries/server.md) | Server information |
| [knot.ai](libraries/ai.md) | AI completion functions |
| [knot.methods](libraries/methods.md) | Register JSON-RPC methods (agent-side only) |
| [knot.methods.schema](libraries/methods-schema.md) | JSON Schema builder for method params and results |
| [knot.mcp](libraries/mcp.md) | MCP tool interaction |
| [knot.skill](libraries/skill.md) | Skills management |
| [knot.slash_command](libraries/slash_command.md) | Slash command management |
| [knot.script](libraries/script.md) | Script management and execution |
| [knot.stack](libraries/stack.md) | Stack definition and instance management |
| [knot.template](libraries/template.md) | Template management |
| [knot.volume](libraries/volume.md) | Volume management |
| [knot.user](libraries/user.md) | User management |
| [knot.group](libraries/group.md) | Group management |
| [knot.role](libraries/role.md) | Role management |
| [knot.vars](libraries/vars.md) | Variables management |
| [knot.permission](libraries/permission.md) | Permission checking |
| [knot.healthcheck](libraries/healthcheck.md) | Space health monitoring (agent-side scripts) |
| [knot.event](libraries/event.md) | Event emission (space-side) and sink accessors (server-side) |
| [knot.audit](libraries/audit.md) | Audit log search and filtering |

---

## Scriptling libraries

The full `scriptling.*` library set is documented on the [Scriptling website](https://scriptling.dev/reference/libraries/), including:

- [`scriptling.grep`](https://scriptling.dev/reference/libraries/scriptling/utilities/grep/) — fast file content search
- [`scriptling.find`](https://scriptling.dev/reference/libraries/scriptling/utilities/find/) — find files by name, type, mtime, and size
- [`scriptling.net.resolve`](https://scriptling.dev/reference/libraries/scriptling/networking/resolve/) — DNS resolution for IP, SRV, and srv+http URLs
- [`scriptling.provision.file`](https://scriptling.dev/reference/libraries/scriptling/provisioning/provision-file/) — idempotent file provisioning
- [`scriptling.provision.fetch`](https://scriptling.dev/reference/libraries/scriptling/provisioning/provision-fetch/) — download files and unpack zip archives over HTTP/HTTPS

Standard Python-compatible libraries (`os`, `pathlib`, `glob`, `tempfile`, `shutil`, `shlex`, `subprocess`, `re`, `json`, `time`, etc.) are also available — see the [Scriptling library reference](https://scriptling.dev/reference/libraries/) for the full list. Availability varies by execution environment; see [Library Availability](../knot-docs/scripting.md#library-availability) for details.

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

- **MCP tool execution**, **event sink scripts**, **remote/space scripts**, and **`knot run-script`** register the Go-provided `knot.apiclient` transport, so the API libraries (`knot.space`, `knot.user`, `knot.group`, `knot.role`, `knot.audit`, `knot.permission`, `knot.vars`, `knot.volume`, `knot.script`, `knot.skill`, `knot.slash_command`, `knot.server`, `knot.template`, `knot.stack`, `knot.pool`, `knot.jobs`), plus `knot.ai` and `knot.mcp`, are available and authenticated automatically.
- **`knot.methods` / `knot.methods.schema`** are agent-side only: remote/space scripts, `knot run-script`, and `knot methods register`. They are not available in MCP tool execution or event sink scripts.
- **`knot.event`** is context-sensitive: `emit()` runs in space-side scripts, MCP tool execution, and external standalone scripts; the payload/metadata accessors run only in event sink scripts.
- **`knot.healthcheck`** runs in every agent-side (space) script — health check scripts, startup scripts, `knot run-script` — but not in MCP tool execution or event sink scripts.
- **Health check scripts** run agent-side in the space and share the full Space environment; they have no `knot.apiclient` transport, so the API libraries are not usable there.

For standalone scripts running outside knot (the scriptling CLI), the Python implementations resolve over HTTP via `knot.apiclient` configuration; `knot.methods`, `knot.event`, and `knot.healthcheck` have no standalone form.

---

## Authentication

Scripts automatically authenticate using the context they're running in — no explicit token handling is needed. The `knot.apiclient` transport is pre-configured by the runtime.
