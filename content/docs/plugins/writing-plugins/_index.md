---
title: Writing Plugins
description: Packaging, metadata declarations, and validation - everything common to plugins written in Scriptling, Go, or both.
type: Overview
tags: [plugins, scripting]
weight: 50
---

Every plugin has the same shape regardless of what its logic is written in: **a script entry file that declares** - plus, optionally, assets and binary components. Whether you write the plugin in [Scriptling](./scriptling/), in [Go](./go/), or mix both, the declarations are identical and live in the same place: the metadata block of the entry file.

This page covers what's common - packaging, the metadata reference, and validation. The [Scriptling](./scriptling/) and [Go](./go/) pages cover the language-specific parts, [Plugin Pages](./pages/) covers what happens when a page handler runs, [Raw HTML](./html/) documents the trusted html column's helper classes and globals, and [MCP Tools](./mcp-tools/) covers exposing handlers as MCP tools.

## Packaging

A plugin is **a folder** in the server's plugins path:

| Layout | Identity | Entry point |
|---|---|---|
| `plugins/metrics/main.py` (+ modules, `assets/`, `libs/`, `bin/`) | `metrics` | `main.py` |

Identity is the filesystem name, which must match `[a-z0-9_-]+` - it becomes part of the plugin's permission namespace (`plugin.<name>.<id>`). A loose `.py` file in the plugins path is not a plugin (it is ignored with a warning) - folders give peers and assets a home and keep one shape for every plugin.

The folder's other `.py` files are modules its handlers can import (`import helpers`) - the module loader is scoped to the plugin folder, so plugins cannot see each other's code. Assets live anywhere in the folder (`assets/` by convention); scriptling libraries in [`libs/`](./scriptling/#scriptling-libs); Go peers in [`bin/`](./go/).

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
# [[tool.knot.menus]]
# label = "Grafana"                                  # required
# url = "https://grafana.internal/d/spaces"          # required: "/", http:// or https://
# permission = "read_metrics"                        # optional: must be declared above
# icon = "assets/chart.svg"                          # plugin's own SVG asset
# ///
```

## Validation

Unknown keys anywhere in `[tool.knot]` are load errors - a typo fails loudly, never silently. The same goes for: a permission reference that isn't declared, a menu or page without its required fields, a path that escapes the plugin's namespace, an icon asset that is missing, not an `.svg`, or unsafe to inline, or logos declared as a half pair. A plugin that fails validation is listed on the [admin plugins page](../managing/) with the reason and is simply unavailable - the server keeps running.


### Permissions

`permissions` is a plain list of ids (`[a-z0-9_]+`). At load knot qualifies them into grant names - `plugin.metrics.read_metrics` - which appear in the role editor under the plugin's name. Grants are stored on roles **as text**, so they mean the same thing on every cluster node regardless of start order, and a removed plugin's grants sit inert until it is reinstalled. See [Managing Plugins](../managing/).

The admin role passes every plugin permission check; no other role gets plugin permissions implicitly.

### Logos

`logo_light` and `logo_dark` are relative paths inside the plugin folder. Declare both for a themed pair, or just one - a single logo serves both themes. They must exist at load and are served at `/plugins/<name>/assets/<path>`; only the declared logo files are reachable. **A declared pair claims the main page logo** - the top bar and the login page use it while the plugin is loaded - unless `server.ui.logo_url` is configured, which wins. If several plugins declare pairs, the first by name wins (the admin inventory shows a warning), so only one plugin should ship one.

### Pages

A `[[tool.knot.pages]]` entry declares an internal page under `/plugins/<name>` served by a handler function, optionally gated by `permission` like a menu item - see [Plugin Pages](./pages/) for the dispatch model. `label` is the page title; a page with `menu_label` also appears in the sidebar under that label (unset means no menu item), inheriting the page's gate and icon. A page with `default = true` becomes the post-login landing page (one page per plugin; if several plugins claim it the first by name wins, with a warning on the admin inventory).

## The dispatch globals

Whatever the dispatch — a page render, a column fetch, an MCP tool call, a field handler, `knot.plugin.call` — the handler runs with three globals bound: `params` (the call's parameters), `request` (`{method, path}`), and **`user`**: a `User` instance describing the requesting user, carrying their groups and permissions with `has_permission` / `in_group` methods (one check for all of it: an integer is a built-in permission id — the `knot.permission` constants — a string a stable key like `"manage_spaces"` or a qualified grant like `"plugin.metrics.read"`), so code can ask who is calling. The metadata gates remain the enforcement boundary; `user` is for in-code decisions the declarations can't express.

The full `User` surface is in [the dispatch globals reference](./scriptling/#the-dispatch-globals) (editors complete it from the `knot.globals.User` stub). The global binds in the *entry script* — which is all a pure-Scriptling plugin needs. When the logic lives in a [Go](./go/) peer, the handler reads `user` and passes what the peer needs across as plain arguments: [how identity reaches the peer](./go/#the-requesting-user).

## MCP tools

`[[tool.knot.mcp_tools]]` exposes a plugin handler as an MCP tool — listed by knot's MCP server, callable by AI assistants, running as the requesting user, optionally gated by permission. No input schema is needed: parameters arrive in the handler's `params`. See [MCP Tools](./mcp-tools/) for the full contract, including calling plugins back from plugin tools via `knot.plugin`.

## Fields

`[[tool.knot.field_handlers]]` declares the functions that back autocomplete template custom fields; types, editor languages and the key-to-text contract are covered in [Fields](fields/).


## Menus and icons

A `[[tool.knot.menus]]` entry adds a link to the sidebar's *More* section - internal (`/...`) or external (`http(s)://...`). Items are visible to any logged-in user unless gated. A `permission` requires one of the user's roles to carry the grant. Items are pinnable like built-in navigation and appear in the global search.

`icon` is a relative path to an **SVG asset in the plugin folder**. The SVG's inner markup is rendered inline with the site's icon styling, so an icon stroked with `currentColor` themes with the UI exactly like knot's own icons - write yours the same way (any heroicons-style 24×24 outline SVG works). Icons are size-capped and sanitized at load: scripts, event handlers, and external references are refused.
