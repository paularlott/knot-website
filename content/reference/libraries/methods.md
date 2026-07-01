---
title: knot.methods
weight: 25
---

Register JSON-RPC methods for the current space from startup scripts or `knot methods register file.py`. Available in agent-side and `knot run-script` contexts only — not in MCP tool execution environments.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Remote/space scripts (startup scripts), `knot methods register`, `knot run-script` | Available (agent-side). The agent installs the registrar that `register()` calls to publish methods to the server. |
| MCP tool execution, event sink scripts, `knot run-script` server mode | Not available. `register()` returns an error if called. |
| Health check scripts, external standalone | Not available. |

---

## Import

```python
from knot.methods import Server
from knot.methods import schema as s
```

---

## Server Class

```python
Server(command, *, type="stdio", timeout=30, args=None, mode="concurrent")
```

Creates a new method server configuration. `command` is the executable to run as the long-running stdio method server. `type` defaults to `"stdio"` (the only currently supported transport).

### Methods

| Method | Description |
|--------|-------------|
| `method(name, *, local_name="", description="", scope="private", keywords=[], groups=[], mcp_tool=False, params=None, result=None, events=[], event_sinks=[])` | Add a method definition |
| `register()` | Validate and publish the current registration. Replaces any previous registration from this space |
| `unregister(name=None)` | Remove all methods (no argument) or one method by name. Stops the method server if all methods are removed |

### Example

```python
from knot.methods import Server
from knot.methods import schema as s

server = Server("./bin/notes-rpc", timeout=30)

server.method(
    name="{{space}}.search",
    local_name="search",
    description="Search indexed notes",
    scope="shared",
    mcp_tool=True,
    params=s.object(
        query=s.string(),
        tag=s.string(),
        limit=s.optional(s.integer(), default=10),
    ),
    result=s.object(),
)
server.register()
```

---

## Concurrency Mode

| Mode | Description |
|------|-------------|
| `"concurrent"` (default) | Many requests may be in flight at once; responses arrive by JSON-RPC id in any order |
| `"serial"` | One request at a time; the next request is sent only after the previous response |

---

## Registration Semantics

- A space can only have one active registration at a time.
- `register()` replaces the space's previous registration entirely.
- `unregister()` with no arguments removes all methods and stops the method server process.
- `unregister("search")` removes just that method and re-publishes the reduced set.

---

## Environment Compatibility

Available in startup scripts, `knot methods register file.py`, and `knot run-script`. Not available in MCP tool execution or health check scripts.
