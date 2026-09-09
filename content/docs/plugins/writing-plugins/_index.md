---
title: Writing Plugins
description: Packaging, metadata declarations, and validation - everything common to plugins written in Scriptling, Go, or both.
type: Overview
tags: [plugins, scripting]
weight: 50
---

Every plugin is **a folder** that declares itself in a `[tool.knot]` table - plus, optionally, assets and binary components. Whether you write the plugin in [Scriptling](./scriptling/), in [Go](./go/), or mix both, the declarations are identical; what differs is only where the `[tool.knot]` table is read from:

- a **pure-script plugin** puts it in the metadata block of `main.py`;
- a **peer plugin** returns it in its [binary peer's handshake](./go/) - so a folder with only `bin/` + `assets/` and no `main.py` is a complete plugin.

Either way knot parses the *same* table the *same* way, and never runs plugin code to learn a declaration.

This page covers what's common - packaging, the metadata reference, and validation. The [Scriptling](./scriptling/) and [Go](./go/) pages cover the language-specific parts, [Plugin Pages](./pages/) covers what happens when a page handler runs, [Plugin Forms](./forms/) is the form field reference and POST envelope contract, [Raw HTML](./html/) documents the trusted html column's helper classes and globals, and [MCP Tools](./mcp-tools/) covers exposing handlers as MCP tools.

## Packaging

A plugin is **a folder** in the server's plugins path, in one of two shapes:

| Layout | Identity | Manifest source |
|---|---|---|
| `plugins/metrics/main.py` (+ modules, `assets/`, `libs/`, `bin/`) | `metrics` | `main.py` metadata block |
| `plugins/metrics/bin/<peer>` (+ optional `assets/`, no `main.py`) | `metrics` | the peer's handshake |

A folder qualifies as a plugin if it has a `main.py` **or** a `bin/` directory. Identity is the filesystem name, which must match `[a-z0-9_-]+` - it becomes part of the plugin's permission namespace (`plugin.<name>.<id>`). A loose `.py` file in the plugins path is not a plugin (it is ignored with a warning) - folders give peers and assets a home and keep one shape for every plugin.

The folder's other `.py` files are modules its handlers can import (`import helpers`) - the sibling-module loader is scoped to the plugin folder, so a plugin's private modules stay private. (This is separate from a plugin's *published* surface: what a plugin exposes under `plugin.<name>` - a `libs/` library or a `bin/` peer - other installed plugins may compose, since installed plugins share one trust domain; see [composition](./scriptling/#composition).) Assets live anywhere in the folder (`assets/` by convention) — or, for a peer plugin, inside the peer itself: a fetcher-serving peer can carry the declared assets in the binary or the script, making the plugin a single file ([single binary](./go/#single-binary-assets-from-the-peer)). Scriptling libraries in [`libs/`](./scriptling/#scriptling-libs); Go peers in [`bin/`](./go/).

## The metadata block

Declarations live in the entry file's metadata block - the `# /// script` comments before the first statement, the same block that declares requirements. One source of truth, lintable with `scriptling --lint`, and readable by an admin without running anything.

Inside knot, `requires-scriptling` is checked against the **embedded scriptling runtime's version**, so a plugin using language features from scriptling 0.24 declares `requires-scriptling = ">=0.24"`. The optional `requires_knot` in `[tool.knot]` is the host bound - the knot version the plugin's use of the plugin system needs, checked against knot's own version at load (`requires_knot = ">=0.34"`). The `dependencies` and `plugins` keys declare what the plugin needs from its environment - including any [binary peers](./go/):

```python
# /// script
# requires-scriptling = ">=0.24"
# dependencies = [
#   "plugin.demolib via demolib >= 1.0.0",   # a binary peer this plugin needs
# ]
# ///
```

## `[tool.knot]` reference

Everything a plugin declares lives under `[tool.knot]`:

```python
# /// script
# requires-scriptling = ">=0.24"
#
# [tool.knot]
# api = 1                                           # plugin system generation (only 1 today; absent = 1)
# version = "1.0.0"                                  # the plugin's own version
# requires_knot = ">=0.34"                           # optional host bound
# description = "Space metrics dashboards."          # shown in the admin inventory
# permissions = ["read_metrics", "export"]           # ids, qualified at load
# logo_light = "assets/logo-light.svg"               # themed pair, relative to the
# logo_dark = "assets/logo-dark.svg"                 #   plugin folder, must exist
#
# [[tool.knot.pages]]
# path = "/dashboard"                                # served at /plugins/metrics/dashboard
# handler = "dashboard_report"                       # function in this file, or "module.fn"
# label = "Metrics Dashboard"                        # page title
# menu_label = "Metrics"                             # set: also a sidebar item under this label
# permission = "read_metrics"                        # optional: gate on a declared permission
# default = false                                    # true: the post-login landing page
# icon = "assets/gauge.svg"                          # plugin's own SVG asset
#
# [[tool.knot.handlers]]
# handler = "export_all"                             # ajax addressable; own gate + plugin-root URL
# permission = "export"                              # optional: gate for this handler everywhere
#
# [[tool.knot.mcp_tools]]
# name = "export_metrics"                            # MCP tool name (defaults to the handler)
# description = "Export fleet metrics as JSON."      # shown to MCP clients
# handler = "export_all"                             # same handlers; params arrive in `params`
# permission = "export"                              # optional: gates listing and calls
#
# [[tool.knot.mcp_tools.parameters]]                 # optional: builds the input schema
# name = "hours"
# type = "int"                                       # string, int, float, bool, list
# description = "Hours to export."
# default = 24                                 # optional
#
# [[tool.knot.field_handlers]]
# label = "Environments"                             # shown in the template editor (defaults to handler)
# handler = "field_environment"                      # serves custom field suggestions; see Fields
#
# icons = ["assets/view.svg"]                        # SVG assets for data-driven row action icons,
#                                                    #   sanitized at load and addressable by path
#
# [[tool.knot.menus]]
# label = "Grafana"                                  # required
# url = "https://grafana.internal/d/spaces"          # required: "/", http:// or https://
# permission = "read_metrics"                        # optional: must be declared above
# icon = "assets/chart.svg"                          # plugin's own SVG asset
# ///
```

## Validation

Unknown keys anywhere in `[tool.knot]` are load errors - a typo fails loudly, never silently. The same goes for: a permission reference that isn't declared, a menu or page without its required fields, a path that escapes the plugin's namespace, an icon asset that is missing, not an `.svg`, or unsafe to inline, or logos declared as a half pair. A plugin that fails validation is listed on the [admin plugins page](../managing/) with the reason and is simply unavailable - the server keeps running.

## Plugin api generations

The plugin system is versioned as a **generation**, declared with `api` in `[tool.knot]` (absent means `1`, today's only generation). A generation covers the whole plugin contract: the `[tool.knot]` table shape, the handler `request`/response contract, and the block document the client renders. The promises that make a future generation safe to ship:

- **Breaking changes happen only behind a new generation.** Within a generation knot may grow *optional* keys - and because unknown keys are load errors, an older knot rejects a newer plugin's keys loudly (failed on the admin page, with the reason) instead of guessing at them.
- **A knot rejects what it doesn't implement.** A plugin declaring an `api` this knot doesn't know fails at load with a message naming both generations - never a mis-parse.
- **Generations coexist.** When an api 2 exists, v1 plugins keep loading unchanged; plugins don't age out of knot.

Version-independent substrate - stable across generations by construction: the folder identity and `[a-z0-9_-]+` naming, `plugin.<name>` handler namespaces, permission grants (stored as text on roles, surviving restarts and reinstalls), the `/plugins/<name>/...` URL space, and asset serving.

`api` answers *which contract*; [`requires_knot`](#the-metadata-block) answers *which knot version* the plugin's use of knot needs. A plugin written against generation 1 features that shipped in knot 0.35 declares `api = 1` (or nothing) plus `requires_knot = ">=0.35"`.


### Permissions

`permissions` is a plain list of ids (`[a-z0-9_]+`). At load knot qualifies them into grant names - `plugin.metrics.read_metrics` - which appear in the role editor under the plugin's name. Grants are stored on roles **as text**, so they mean the same thing on every cluster node regardless of start order, and a removed plugin's grants sit inert until it is reinstalled. See [Managing Plugins](../managing/).

The admin role passes every plugin permission check; no other role gets plugin permissions implicitly.

### Logos

`logo_light` and `logo_dark` are relative paths inside the plugin folder. Declare both for a themed pair, or just one - a single logo serves both themes. They must exist at load and are served at `/plugins/<name>/assets/<path>`; only the declared logo files are reachable. **A declared pair claims the main page logo** - the top bar and the login page use it while the plugin is loaded - unless `server.ui.logo_url` is configured, which wins. If several plugins declare pairs, the first by name wins (the admin inventory shows a warning), so only one plugin should ship one.

### Pages

A `[[tool.knot.pages]]` entry declares an internal page under `/plugins/<name>` served by a handler function, optionally gated by `permission` like a menu item - see [Plugin Pages](./pages/) for the dispatch model. `label` is the page title; a page with `menu_label` also appears in the sidebar under that label (unset means no menu item), inheriting the page's gate and icon. A page with `default = true` becomes the post-login landing page (one page per plugin; if several plugins claim it the first by name wins, with a warning on the admin inventory).

## Handler addressing and the `request` argument

Every handler is addressed **`plugin.<name>.<function>`** and receives a single argument, `request` - there are no implicit globals. Whatever the dispatch (a page render, a column fetch, an MCP tool call, a field handler, `knot.plugin.call`), the handler is called as `handler(request)`:

```python
def dashboard_report(request):
    method = request["method"]   # "GET" | "POST" | "CALL" (MCP) | the knot.plugin.call method
    path   = request["path"]     # "/plugins/metrics/dashboard"
    params = request["params"]   # dict: query parameters merged over any POST body
    who    = request["user"]     # inert identity snapshot (a dict) - see below
    ...
```

A bare handler declaration (`handler = "dashboard_report"`) resolves against the plugin's own namespace - the folder name for a Scriptling `main.py` (with `-` mapped to `_`), or the peer's handshake name for a [Go](./go/) peer. A declaration can also name another plugin explicitly (`handler = "plugin.other.export"`) - that is [cross-plugin composition](./scriptling/#composition).

### `request["user"]` is data; `knot.identity` is authority

`request["user"]` is a plain, serializable **dict** - `id`, `name`, `is_admin`, `groups`, `permissions` (stable snake_case keys), `plugin_permissions` (qualified grants). It is passed *data*: no round trip, no methods, and it crosses the wire unchanged to a [Go peer](./go/). Use it to branch on *who is calling*.

Anything that acts with the user's authority - or wants the authoritative permission check, where the admin role passes everything - uses `knot.identity.user()`, a real `User` object with `has_permission` / `in_group`, backed by the gated loopback:

```python
def export_all(request):
    import knot.identity

    if not knot.identity.user().has_permission("plugin.metrics.export"):
        return {"error": "forbidden"}
    ...
```

The metadata gates remain the enforcement boundary knot applies before the handler ever runs; `request["user"]` and `knot.identity` are for the in-code decisions the declarations can't express. The `knot.identity` `User` surface (the `has_permission` argument forms) is in [the identity reference](./scriptling/#identity); editors complete it from the `knot.identity` stub.

## MCP tools

`[[tool.knot.mcp_tools]]` exposes a plugin handler as an MCP tool — listed by knot's MCP server, callable by AI assistants, running as the requesting user, optionally gated by permission. No input schema is needed: parameters arrive in the handler's `params`. See [MCP Tools](./mcp-tools/) for the full contract, including calling plugins back from plugin tools via `knot.plugin`.

## Fields

`[[tool.knot.field_handlers]]` declares the functions that back autocomplete template custom fields; types, editor languages and the key-to-text contract are covered in [Fields](fields/). (Template custom fields are collected on the space form - a plugin's *own* form fields, on its pages, are a different contract: [Plugin Forms](./forms/).)


## Menus and icons

A `[[tool.knot.menus]]` entry adds a link to the sidebar's *More* section - internal (`/...`) or external (`http(s)://...`). Items are visible to any logged-in user unless gated. A `permission` requires one of the user's roles to carry the grant. Items are pinnable like built-in navigation and appear in the global search.

`icon` is a relative path to an **SVG asset in the plugin folder**. The SVG's inner markup is rendered inline with the site's icon styling, so an icon stroked with `currentColor` themes with the UI exactly like knot's own icons - write yours the same way (any heroicons-style 24×24 outline SVG works). Icons are size-capped and sanitized at load: scripts, event handlers, and external references are refused.
