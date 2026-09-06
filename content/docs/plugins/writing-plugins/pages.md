---
title: Plugin Pages
description: Layout-driven plugin pages, rows, columns, per-panel data handlers.
weight: 20
---

A `[[tool.knot.pages]]` entry serves a live page under `/plugins/<name><path>`. The page handler is pure **layout logic**: it returns rows of columns, each column declaring its type, its own data handler and refresh. The client renders the shell instantly (with loaders), then fetches each column's data independently - a slow panel never delays the page, a failing panel is an error card in its column, and each panel refreshes on its own timer.

```python
# [[tool.knot.pages]]
# path = "/home"
# handler = "dashboard"
# ...
def dashboard():
    return {"rows": [
        {"title": "Fleet status", "columns": [
            {"id": "kpi", "type": "stats", "handler": "kpi", "refresh": 30},
        ]},
        {"columns": [
            {"id": "cpu", "type": "chart", "title": "CPU", "handler": "cpu_chart", "refresh": 10, "width": 3},
            {"id": "spaces", "type": "table", "title": "Spaces", "handler": "spaces_table", "width": 1},
        ]},
    ]}
```

Any other return value renders as a read-only key-value view.

## Rows and columns

The document is always `{"rows": [...]}`. A row has an optional `title`, an optional `style: "card"` (the whole row is one card and the columns are unstyled panels; the default styles each column as its own card), optional `permission`/`group` gates, and a `columns` list. A column has:

- `id` - the data-binding key (auto-generated as `r<row>c<col>` when omitted); identifies the column for refresh targeting. Data is fetched with `?_col=<handler>` - the handler name itself, proxied straight through after the page gate.
- `type` - what renders the column: `stat`, `chart`, `table`, `form`, `markdown`, `html`, `text`, `bar`. Markdown covers code (fenced blocks) and lists (rendered with knot's checkmark styling); `text` is the literal type - escaped, whitespace preserved, no markdown semantics, right for timestamps and captions.
- `title` - the column heading.
- `handler` - the function that supplies this column's data. **Self-contained**: each call runs in a fresh environment as the requesting user, so compute what you need per call.
- `refresh` - seconds (5-3600); the client re-fetches just this column.
- `width` - 1 to 4 (default 4); the row is always full width, divided into N columns on wide screens and stacking on narrow ones.
- `permission` / `group` - gates enforced by knot; a row left with no columns is never sent.

## Column handlers

Each handler returns JSON for its type:

- `stat` - a single KPI card `{label, value, unit?, delta?, accent?}`; a KPI row is a row of stat columns.
- `chart` - `{chart_type: line|bar|doughnut|pie, labels, datasets: [{name, data, color?}], height?}`; drawn by knot's bundled chart.js.
- `table` - `{columns: [{key, label, badge?}], rows: [...]}` plus optional `actions` (below).
- `form` - see below.
- `markdown` - `{markdown: "..."}`; GFM rendered server-side into knot's prose (trusted like html: plugins are admin-installed).
- `html` - `{html: "..."}`; trusted inline markup - style with the `kp-*` helper classes or inline styles, never Tailwind classes (knot's Tailwind compile only covers knot's own markup).

## Forms: one handler, two faces

A form column's handler branches on `request.method`. GET returns the definition; POST receives the submitted fields in `params` and returns an **envelope**:

```python
def widget_form():
    if request.method == "POST":
        name = params.get("widget_name", "")
        if name == "":
            return {"status": "error", "message": "A widget needs a name.",
                    "field_errors": {"widget_name": "Required."}}
        return {"status": "ok", "message": "Widget created.", "refresh": True}
    return {"fields": [
        {"type": "hidden", "name": "action", "value": "create"},
        {"type": "text", "name": "widget_name", "label": "Name"},
        {"type": "autocomplete", "name": "owner", "label": "Owner", "dynamic_options": True},
    ], "submit": "Create widget"}
```

On `ok` the client shows the message as a notification and refreshes the columns the envelope names (`refresh: ["spaces"]`) or all of them (`refresh: true`). On `error` the message notifies and `field_errors` map back onto the open form's inputs. Field types: `text`, `number`, `select` (requires `options`), `autocomplete` (fixed `options` or `dynamic_options: true` - the client asks the form column's own handler with `_data=<field name>`, and that handler returns `{"options": [...]}` before anything else), and `hidden`. Autocomplete is pick-or-create; suggestions may be key/text pairs (`{key, text}`) where the user picks by text and the form stores the key.

## Table actions

A table column may declare per-row buttons:

```python
{"id": "spaces", "type": "table", "handler": "spaces_table", "width": 3, "actions": [
    {"label": "Delete", "style": "danger", "action": "delete", "confirm": "Delete this space?"},
]}
```

`action` buttons POST `{action, key}` (the row's `id` or `name`) to the column's endpoint and handle the envelope like a form; `style: "danger"` renders red; `confirm` arms an inline two-step confirmation.

## The `html` column and `kp-*` helpers

Trusted html columns can carry inline CSS and Alpine (`window.Alpine`). The `kp-*` classes ship in knot's CSS unconditionally and adapt to the light/dark themes: `kp-text`/`kp-muted`, `kp-accent`/`kp-info`/`kp-success`/`kp-warning`/`kp-danger`, `kp-title`/`kp-label`, `kp-mono`, `kp-card`, `kp-flex`, `kp-grid`.

## Accessibility

Presentation lives in knot's renderer, so pages inherit it: semantic headings/tables/labels, state never by colour alone, `role="status"` loaders per column, charts labelled with a text summary, notifications through a live region, and refreshes defer while the user is reading (focus/pointer in the region). The trusted `html` column is excluded from the guarantee.

## The dispatch model

When a user opens the page, knot checks the page gate (declared permission and/or group - **knot enforces, plugins can't forget it**), evaluates the entry file, calls the handler as the requesting user, enforces the row/column gates, and serves the layout. Each `?_col` fetch proxies straight to that handler (auth and the page gate checked, then the call - no layout re-resolution). Handler environments: the scriptling standard library, data formats, templating, text processing (jailed to the plugin folder), `scriptling.ai`, the [`knot.*` libraries](../../../scripting/) as the requesting user, and binary peers as `plugin.<name>` imports. No outbound networking, no container/nomad, no filesystem outside the plugin folder.

## Examples

The `dashboard` example is a real landing page on this contract - live `knot.*` aggregates and history, and it claims the post-login default with `default = true`; `demo-scriptling`'s showcase exercises every column type plus a one-handler form; `demo-go` measures real peer latencies into charts.
