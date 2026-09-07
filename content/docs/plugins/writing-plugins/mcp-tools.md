---
title: MCP Tools
description: Exposing plugin handlers as MCP tools for AI assistants.
weight: 35
---

A plugin can expose its handlers as **MCP tools**: they are listed by knot's MCP server and callable by any MCP client — AI assistants included — running as the requesting user through the same dispatch as every other handler call.

## Declaring a tool

`[[tool.knot.mcp_tools]]` in the plugin's metadata turns a handler into a tool:

```python
# /// script
# requires-scriptling = ">=0.24"
#
# [tool.knot]
# version = "1.0.0"
# permissions = ["export"]
#
# [[tool.knot.mcp_tools]]
# name = "export_metrics"                 # optional, defaults to the handler name
# description = "Export fleet metrics as JSON for a time range."
# handler = "export_metrics"
# permission = "export"                   # optional: gates listing and calls
# ///
```

The `description` is required — MCP clients list it next to the tool name. The `permission` (a `[tool.knot]` permission id, qualified at load) gate applies at **both** listing and call time: a user without the grant never sees the tool, and a direct call by name is refused before the handler runs. An empty gate means any MCP user.

**No input schema is declared, and none is needed.** The MCP input schema is an empty object, and the tool's parameters are bound twice — as the handler's `params` dict and as the MCP tool context — so `scriptling.mcp.tool` works exactly as it does in any other MCP tool. Write the handler the way script tools are written:

```python
def export_metrics():
    import scriptling.mcp.tool as tool

    hours = tool.get_int("hours", 24)
    import knot.space as space
    ...
    tool.return_object({"exported": rows})
```

`tool.get_string`/`get_int`/`get_bool`/`get_list` (and their `_list` variants) read the caller's arguments; `return_string`, `return_object` and `return_toon` set the response. A plain `return` also works — strings become text responses, anything else is JSON-encoded — so handlers shared with pages (which use `params` and plain returns) serve as tools unchanged.

### Declaring parameters

By default the tool's input schema is an empty object — permissive, but MCP clients (and LLMs) get no argument hints. Declare parameters and they build the schema the client sees:

```toml
# [[tool.knot.mcp_tools]]
# name = "export_metrics"
# description = "Export fleet metrics as JSON for a time range."
# handler = "export_metrics"
#
# [[tool.knot.mcp_tools.parameters]]
# name = "hours"                                # required, an identifier
# type = "int"                                  # string (default), int, float, bool, list
# description = "Hours to export."              # shown to the client
# default = 24
#
# [[tool.knot.mcp_tools.parameters]]
# name = "scope"
# type = "string"
# description = "What to export."
# required = true
```

Types map to JSON schema types (`int` → `integer`, `float` → `number`, `list` → `array`), and `required` parameters collect into the schema's `required` list. The declaration is documentation and client ergonomics — parameters still arrive in the handler's `params` dict untyped, exactly as before.

## The identity surface

Handlers can self-check who is calling: every dispatch binds a `user` global — a `User` instance with `name`, `id`, `is_admin`, `groups`, `permissions`, `plugin_permissions` fields and `has_permission`/`in_group` methods — one check for all of it: an integer is a built-in permission id, a string a stable key or a qualified grant (script tools see the same global). The metadata gates remain the enforcement boundary (knot refuses before plugin code runs); `user` is for in-code decisions — adapting output, refusing edge cases the declarations can't express:

```python
def export_metrics():
    import scriptling.mcp.tool as tool

    if not user.is_admin and not user.in_group("platform"):
        tool.return_error("platform group only")
    ...
```

## Names and precedence

Tool names share one namespace with knot's boot tools and script tools. Two plugins exposing the same name cannot both load — the first by plugin name wins and the later fails with the collision named on the admin Plugins page. A script with the same name shadows the plugin tool, matching execution order: boot tools, then scripts, then plugin tools.

## Calling plugins from tools

The [`knot.plugin`](../../../reference/libraries/plugin/) library calls declared handlers; what a call may reach depends on who wrote it:

- **Plugin-exposed tools** (and plugin handlers) may call any plugin's *declared* handlers in-process through the `knot.plugin` library — same trust domain:

  ```python
  import knot.plugin as kp
  result = kp.call("metrics", "export_all", {"range": "1h"})
  ```

  Only `[[tool.knot.handlers]]`-declared handlers are addressable — the same contract the browser's `pluginFetch` uses — and the declaration's gate is enforced for the **requesting user** at the call boundary: the call fails with `permission denied` and the plugin's code never runs.

- **User-created tools** (defined in the web interface, stored in the database) get the same `knot.plugin.call`, but it rides the **in-process loopback** — the same authenticated transport the `knot.*` libraries use — through the real web dispatch, so the declared gate applies exactly as for a browser fetch. User code never invokes plugin handler code in-process:

  ```python
  import knot.plugin as kp
  result = kp.call("metrics", "export_all", {"range": "1h"})
  # POST (params as a JSON body) for handlers that branch on request.method:
  result = kp.call("metrics", "submit", {"range": "1h"}, method="POST")
  ```

  A refused gate raises `permission denied`, an undeclared handler or unknown plugin is not addressable, and the handler runs as the requesting user with the `user` global bound — it can self-check exactly as a page handler does.

## Plugin exports in user tools

A plugin's **scriptling libraries** (`libs/*.py`) are importable in user-created tools as `plugin.<name>` — functions, classes and constants, evaluated in-process. This is the plugin author's decision to publish compute for reuse; no metadata gate applies to an import, so the exported code carries its own:

```python
# libs/calc.py — the plugin exports this
import knot.identity

def export_report():
    if not knot.identity.user().has_permission("plugin.metrics.export"):
        raise Exception("plugin.metrics.export not granted")
    return {"rows": []}
```

`knot.identity.user()` returns the same `User` instance the `user` global holds — module code (exported libraries, lib scripts) can't see the globals, whose scope is the calling program, so the identity library carries the instance. The permission check is the plugin's own: a user without `plugin.metrics.export` gets the refusal, whoever's tool invoked it. Binary (Go) peers are importable the same way — through the scriptling plugin support, the host-side stubs auto-generated from each peer's handshake, so a user tool calls into the already-spawned peer process exactly as plugin handlers do (the peer-lifecycle control surface is not part of it). `demo-scriptling` ships a working self-gate example: `gated_report()` in its `libs/calc.py` refuses users without `plugin.demo-scriptling.view_dashboard`; `demo-go`'s `demolib` is the Go twin, importable from user tools as `plugin.demolib`.

## Example

`demo-scriptling` exposes its `echo_word` handler as an MCP tool — see `examples/plugins/demo-scriptling/main.py` in the knot repository. The built-in tools knot itself ships are listed in [MCP Tools](../../../ai/mcp-tools/); connecting clients are covered in [MCP](../../../ai/mcp/).
