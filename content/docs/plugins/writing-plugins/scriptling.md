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

A page's `handler` is `"fn"` for a function in the entry file, or `"module.fn"` for a function in a sibling module. Handlers take no arguments; the request's query parameters arrive as the `params` dict, and the return value is a rows/columns layout document (see [Plugin Pages](../pages/)) or a plain dict (key-value view). Column handlers are self-contained: each runs as the requesting user with fresh `params` and a `request` object (`request.method` distinguishes a form's GET definition from its POST submit), on a clean module state — environments are pooled per plugin and bound to the requesting user per call, so nothing persists between requests.

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

