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
# groups = ["platform"]                      # optional
# ///
```

The `description` is required — MCP clients list it next to the tool name. The `permission` (a `[tool.knot]` permission id, qualified at load) and `groups` (a list — the tool applies to members of any listed group) gates apply at **both** listing and call time: a user without the grant never sees the tool, and a direct call by name is refused before the handler runs. Both empty means any MCP user.

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

The reverse direction works too. Built-in and user-defined MCP tools (and plugin handlers themselves) can call any plugin's *declared* handlers in-process through the `knot.plugin` library:

```python
import knot.plugin as kp
result = kp.call("metrics", "export_all", {"range": "1h"})
```

Only `[[tool.knot.handlers]]`-declared handlers are addressable — the same contract the browser's `pluginFetch` uses — and the declaration's gate is enforced for the **requesting user** at the call boundary. A user-defined tool cannot reach a handler its user lacks permission for; the call fails with `permission denied` and the plugin's code never runs.

## Example

`demo-scriptling` exposes its `echo_word` handler as an MCP tool — see `examples/plugins/demo-scriptling/main.py` in the knot repository. The built-in tools knot itself ships are listed in [MCP Tools](../../../ai/mcp-tools/); connecting clients are covered in [MCP](../../../ai/mcp/).
