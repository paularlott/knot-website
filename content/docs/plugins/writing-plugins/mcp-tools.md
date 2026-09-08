---
title: MCP Tools
description: Exposing plugin handlers as MCP tools for AI assistants.
weight: 35
---

A plugin can expose its handlers as **MCP tools**: they are listed by knot's MCP server and callable by any MCP client — AI assistants included — running as the requesting user through the same dispatch as every other handler call. Like every handler, a tool handler takes a single `request` argument and is addressed `plugin.<namespace>.<fn>`.

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

**No input schema is declared, and none is needed.** The MCP input schema is an empty object, and the tool's parameters are bound twice — in the handler's `request["params"]` dict and as the MCP tool context — so `scriptling.mcp.tool` works exactly as it does in any other MCP tool. Write the handler the way script tools are written:

```python
def export_metrics(request):
    import scriptling.mcp.tool as tool

    hours = tool.get_int("hours", 24)
    import knot.space as space
    ...
    tool.return_object({"exported": rows})
```

`tool.get_string`/`get_int`/`get_bool`/`get_list` (and their `_list` variants) read the caller's arguments; `return_string`, `return_object` and `return_toon` set the response. A plain `return` also works — strings become text responses, anything else is JSON-encoded — so handlers shared with pages (which read `request["params"]` and plain returns) serve as tools unchanged.

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

Types map to JSON schema types (`int` → `integer`, `float` → `number`, `list` → `array`), and `required` parameters collect into the schema's `required` list. The declaration is documentation and client ergonomics — parameters still arrive in the handler's `request["params"]` dict untyped, exactly as before.

## The identity surface

Handlers can self-check who is calling. `request["user"]` carries the caller as inert data (`name`, `id`, `is_admin`, `groups`, `permissions`, `plugin_permissions`) - use it to branch on who is asking. Any permission **check** uses [`knot.identity`](../scriptling/#identity), a real `User` object with `has_permission`/`in_group` where the admin role passes everything. The metadata gates remain the enforcement boundary (knot refuses before plugin code runs); these are for the in-code decisions the declarations can't express — adapting output, refusing edge cases:

```python
def export_metrics(request):
    import scriptling.mcp.tool as tool
    import knot.identity

    user = knot.identity.user()
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
  # POST (params as a JSON body) for handlers that branch on request["method"]:
  result = kp.call("metrics", "submit", {"range": "1h"}, method="POST")
  ```

  A refused gate raises `permission denied`, an undeclared handler or unknown plugin is not addressable, and the handler runs as the requesting user with `request["user"]` set and `knot.identity` bound — it can self-check exactly as a page handler does.

## The trust boundary: import vs call

Installed plugins are one trust domain sharing a single **plugin pool** - the exposed surfaces (`libs/*.py` and peers) importable as `plugin.<name>`. That pool is *attached* to plugin handler and plugin-tool environments, so those may `import plugin.<other>` and use another plugin's functions, classes and constants directly, ungated - [composition](../scriptling/#composition) in-process.

User-created tools are the untrusted side: the plugin pool is **not** attached to their environment, so they cannot `import plugin.<name>` at all. This attach/not-attach split is the structural isolation boundary. A user tool reaches a plugin only through [`knot.plugin.call`](../../../reference/libraries/plugin/) over the gated loopback, where the declared handler's gate is enforced for the requesting user - the same contract shown above.

Because that call rides the real web dispatch, the plugin's handler self-gates on the caller exactly as a page handler would - `request["user"]` for the caller's data, `knot.identity` for the authoritative check:

```python
# a [[tool.knot.handlers]]-declared handler the plugin exposes
import knot.identity

def export_report(request):
    if not knot.identity.user().has_permission("plugin.metrics.export"):
        raise Exception("plugin.metrics.export not granted")
    return {"rows": []}
```

The permission check is the plugin's own: a user without `plugin.metrics.export` gets the refusal, whoever's tool invoked it. `knot.plugin.call` reaches a plugin's **declared handlers** (pages, `[[tool.knot.handlers]]`, MCP tools) — never its raw library exports; those are import-only, and imports are trusted-plugin-to-trusted-plugin. `demo-scriptling` ships a self-gating library export, `gated_report()` in its `libs/calc.py`, which refuses users without `plugin.demo-scriptling.view_dashboard` (`demo-go`'s `demolib` is the Go twin): because a composing plugin imports it ungated, the export makes its own `knot.identity` check — the discipline the trust domain relies on for shared compute.

## Example

`demo-scriptling` exposes its `echo_word` handler as an MCP tool — see `examples/plugins/demo-scriptling/main.py` in the knot repository. The built-in tools knot itself ships are listed in [MCP Tools](../../../ai/mcp-tools/); connecting clients are covered in [MCP](../../../ai/mcp/).
