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
tools = mcp.list_tools()
```

---

## Environment Compatibility

Each library's availability depends on where the script runs. Not every library is available in every context — most notably, MCP tool execution, event sink and plugin handler environments do **not** provide `knot.methods`, and MCP tool and event sink environments have no system access libraries. Every reference page opens with an **Execution Environment** table showing exactly where that library works.

Summary of the embedded execution contexts:

- **MCP tool execution**, **event sink scripts**, **plugin handlers**, **remote/space scripts**, and **`knot run-script`** register the Go-provided `knot.apiclient` transport, so the API libraries (`knot.space`, `knot.user`, `knot.group`, `knot.role`, `knot.audit`, `knot.files`, `knot.permission`, `knot.vars`, `knot.volume`, `knot.script`, `knot.skill`, `knot.slash_command`, `knot.server`, `knot.template`, `knot.stack`, `knot.pool`, `knot.jobs`, `knot.token`), plus `knot.ai` and `knot.mcp`, are available and authenticated automatically.
- **`knot.methods` / `knot.methods.schema`** are agent-side only: remote/space scripts, `knot run-script`, and `knot methods register`. They are not available in MCP tool execution, event sink scripts or plugin handlers.
- **`knot.event`** is context-sensitive: `emit()` runs in space-side scripts, MCP tool execution, plugin handlers, and external standalone scripts; the payload/metadata accessors run only in event sink scripts, where `emit()` is not available.
- **`knot.healthcheck`** runs in every agent-side (space) script — health check scripts, startup scripts, `knot run-script` — but not in MCP tool execution, event sink scripts or plugin handlers.
- **`knot.identity`** and **`knot.plugin`** are server-side only: MCP tool execution, event sink scripts and plugin handlers.
- **Health check scripts** run agent-side in the space and share the full Space environment; they have no `knot.apiclient` transport, so the API libraries are not usable there.

For standalone scripts running outside knot (the scriptling CLI), the Python implementations resolve over HTTP via `knot.apiclient` configuration (`knot.event.emit()` included); `knot.methods`, the `knot.event` sink accessors, `knot.healthcheck`, `knot.identity` and `knot.plugin` have no standalone form.

---

## Authentication

Scripts automatically authenticate using the context they're running in — no explicit token handling is needed. The `knot.apiclient` transport is pre-configured by the runtime.
