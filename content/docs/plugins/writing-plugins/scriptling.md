---
title: In Scriptling
description: Write the plugin entry, handlers, and modules in Scriptling - knot's scripting language.
type: Guide
tags: [plugins, scripting]
weight: 10
---

The entry file (`main.py`, or the single `.py`) is a [Scriptling](https://scriptling.dev/) script: it carries the [metadata declarations](../) and defines the handler functions your pages call. Nothing in it runs at load - knot parses the declarations only, and the code below executes per-request when a page is opened.

`requires-scriptling` is checked against the **embedded scriptling runtime's version** - it bounds the language features the plugin's code may use, so `>=0.24` means scriptling 0.24 or newer regardless of the knot version wrapping it. A plugin asking for a newer runtime than the embedded one fails to load, with the requirement named on the admin Plugins page. Development builds (a scriptling replace directive) carry no embedded version and skip the check. For the host side, `[tool.knot]` takes an optional `requires_knot = ">=0.34"` - the knot version the plugin's use of the plugin system needs, checked against knot's own version at load.

```python
# /// script
# requires-scriptling = ">=0.24"
#
# [tool.knot]
# version = "1.0.0"
# description = "Company dashboards."
# permissions = ["view_dashboard"]
#
# [[tool.knot.pages]]
# path = "/dashboard"
# handler = "dashboard_report"
# permission = "view_dashboard"
# menu_label = "Dashboard"
# icon = "assets/gauge.svg"
# ///

"""Company metrics plugin."""


def dashboard_report():
    # The layout: rows of columns, each column with its own data handler.
    return {"rows": [
        {"columns": [
            {"id": "kpi", "type": "stats", "handler": "kpi", "refresh": 30},
        ]},
        {"columns": [
            {"id": "spaces", "type": "table", "title": "Spaces",
             "handler": "spaces_table", "width": 4},
        ]},
    ]}


def kpi():
    import knot.space as space

    spaces = space.list()                  # runs as the requesting user
    return [{"label": "Spaces", "value": len(spaces)},
            {"label": "Range", "value": params.get("range", "24h")}]


def spaces_table():
    import knot.space as space

    rows = []
    for s in space.list():
        rows.append({"name": s.get("name", "?")})
    return {"columns": [{"key": "name", "label": "Space"}], "rows": rows}
```

## Handlers

A page's `handler` is `"fn"` for a function in the entry file, or `"module.fn"` for a function in a sibling module. Handlers take no arguments; the request's query parameters arrive as the `params` dict, the requesting user is the [`user` global](#the-dispatch-globals), and the return value is a rows/columns layout document (see [Plugin Pages](../pages/)) or a plain dict (key-value view). Column handlers are self-contained: each runs as the requesting user with fresh globals and a clean module state — environments are pooled per plugin and bound to the requesting user per call, so nothing persists between requests.

## Modules

A folder plugin's other `.py` files are importable (`import helpers`, `import helpers.sub as sub`) - the loader is scoped to the plugin folder. Keep helpers beside `main.py`; the entry stays the single place declarations live.

```python
# helpers.py
def format_duration(seconds):
    ...

# main.py handler
def dashboard_report():
    import helpers
    return {"uptime": helpers.format_duration(3600)}
```

## The environment in one paragraph

Handlers run in an environment bound to the requesting user (pooled per plugin; each call is Reset, rebound to the user and starts from a clean module state): the scriptling standard library and data/text tooling, filesystem access **jailed to the plugin's own folder**, no outbound networking (`requests`, `wait_for`) and no container/nomad libraries, plus the [`knot.*` libraries](../../../scripting/) acting as the requesting user and the invoking user's own `lib` scripts. If the plugin ships [binary peers](../go/), they are importable as `plugin.<name>`. The full details are on the [Plugin Pages](../pages/) page.

## Scriptling libs

A plugin's exports do not have to be Go — they can be **scriptling libraries**, loaded in-process by knot's embedded scriptling runtime: no subprocess, no CLI on the host, no protocol hop. A library is a `.py` file in the plugin's `libs/` folder:

```
myplugin/
  main.py            handlers and metadata
  libs/
    calc.py          a scriptling library
  bin/               Go peers, if any
```

The library is ordinary scriptling — functions, classes with `__init__` and stateful methods, constants. Its **public surface** (names not prefixed with `_`) becomes the `plugin.<name>` import in the plugin's handler environments, evaluated in-process on first import inside the same jail and trust domain as the handlers:

```python
# libs/calc.py
MAX = 100

def add(a, b):
    """Add two numbers."""
    return a + b

class Counter:
    """A stateful counter."""
    def __init__(self, step):
        self.step = step
        self.n = 0
    def next(self):
        self.n = self.n + self.step
        return self.n
```

```python
# main.py — consuming it
def add_up():
    import plugin.calc as calc

    c = calc.Counter(4)
    return {"sum": calc.add(2, 3), "first": c.next(), "second": c.next()}
```

**Version**: the optional `[tool.knot.lib]` table in the library's metadata block declares its version (default `"1.0"`), and the consuming plugin's dependency validates against it exactly as Go peer handshakes do:

```python
# libs/calc.py
# /// script
# [tool.knot.lib]
# version = "1.5"
# ///
```

with `"plugin.calc via calc >= 1.0.0"` in main.py's `dependencies`. Choose Go for CPU-heavy work, native libraries or a separate trust boundary; choose scriptling for pure-compute helpers that travel with the plugin as source.

`demo-scriptling` ships a working library — `libs/calc.py` (a constant, `add`/`scale`, the `Counter` class and a self-gating `gated_report()`), exercised by the *Plugin peers* row on its showcase page and declared as `plugin.calc via calc >= 1.0` in its metadata. Its Go twin is `demo-go`'s `demolib` (functions plus the `Counter` class over the plugin protocol).

Libraries travel beyond the plugin too: **user-created MCP tools** import them the same way (`import plugin.calc as calc`, `import plugin.demolib as demolib` — scriptling and Go peers alike, the Go ones through the host-side stubs scriptling auto-generates from the peer's handshake). The plugin publishes that compute for reuse, and because no metadata gate applies to an import, the peer's code self-gates on the requesting user via `knot.identity.user()` ([the contract](./mcp-tools/#plugin-exports-in-user-tools)). Handler code, which runs in the main program's scope, reads the `user` global directly; libraries are modules, so they use [`knot.identity`](../../../reference/libraries/identity/).

## The dispatch globals

Every handler call - pages, MCP tools, field handlers, `knot.plugin.call` - receives its world through three globals (script tools get `user` too):

- **`params`** - the call's parameters as a dict. On a page it is the query string (plus any POST body on submits); as an MCP tool it is the client's JSON arguments; `scriptling.mcp.tool.get_string` and friends read the same values.
- **`request`** - `{method, path}`: how the handler was reached. `request.method` distinguishes a form's GET definition from its POST submit.
- **`user`** - a `User` instance describing the requesting user:

| Member | Kind | Meaning |
|---|---|---|
| `user.id` | field | the user's id |
| `user.name` | field | the user's login name |
| `user.is_admin` | field | whether the user holds the fixed admin role |
| `user.groups` | field | the groups the user belongs to |
| `user.permissions` | field | stable snake_case keys of the built-in permissions the user holds (`"manage_spaces"`, `"use_mcp_server"`, ...) |
| `user.plugin_permissions` | field | qualified plugin grants (`"plugin.metrics.read"`) the user holds |
| `user.has_permission(key)` | method | permission check — the argument picks: an integer is a built-in permission id (the `knot.permission` constants), a `"plugin."`-prefixed string a qualified grant, any other string a built-in's stable key; admins pass every check |
| `user.in_group(name)` | method | membership of one group |

Permission keys are stable identifiers — display names are for the role editor and may be reworded, keys never change. One method answers all of it because the forms can't collide: an integer names a built-in by id (`knot.permission.MANAGE_SPACES`), and among strings qualified grants always start with `plugin.`, which no built-in key contains. The metadata gates knot enforces before code runs remain the security boundary; `user` is for in-code decisions - adapting output, refusing edge cases the declarations cannot express. The type is stubbed as `knot.globals.User` in the editor completions.

## Testing

The entry file is a normal scriptling script - anything it declares can be checked with the Scriptling CLI:

```sh
scriptling --lint plugins/metrics/main.py     # validates the metadata block
scriptling plugins/metrics/main.py            # runs it (handlers just won't be called)
```

Handlers that only compute can be exercised directly from the CLI during development.

## Fields

A field handler works like a page handler but is only ever asked for suggestions, so it fast and runs as the requesting user:

```python
# [[tool.knot.field_handlers]]
# label = "Spaces you own"
# handler = "field_my_spaces"
# ///

def field_my_spaces():
    import knot.space as space
    options = []
    for s in space.list():
        options.append({"key": s.get("id", ""), "text": s.get("name", "?")})
    return {"options": options}
```

Bind a *template custom field* of type `autocomplete` to `plugin.<your-plugin>.field_my_spaces` in the template editor (wrench icon) and the space form shows each space as its name, storing the space id as the variable's value.

