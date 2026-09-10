---
title: Plugin Forms
description: Form columns and form popups - the field reference and the POST envelope contract.
tags: [plugins, scripting]
weight: 22
---

A plugin form is **one handler with two faces**: the same function answers the GET that renders the form and the POST that submits it. Forms appear as a [form column](../pages/) in a page layout or as a **form popup** opened from a table action - the contract is identical, only where the form lives differs.

## The one-handler contract

GET returns the definition; POST receives the submitted fields in `request["params"]` and returns an **envelope**:

```python
def widget_form(request):
    if request["method"] == "POST":
        params = request["params"]
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

The GET definition is `{fields: [...], submit?: "...", cancel?: "...", auto_submit?: true}` - `submit` defaults to `Apply`, `cancel` (which defaults to `Cancel`) adds a second button, and `auto_submit` turns the form into a filter (below).

## Fields

Every field is `{type, name, label?, ...}` - `name` is the key in `request["params"]` on POST:

| Type | Keys | Notes |
|---|---|---|
| `text` | `value?`, `placeholder?` | Single-line text. |
| `number` | `value?`, `placeholder?` | Numeric input; the value still arrives as a string. |
| `textarea` | `language?`, `rows?`, `placeholder?`, `wrap?`, `value?` | Multiline, edited with the same bundled Ace editor knot's own forms use. |
| `select` | `options` (required), `value?` | Dropdown; `options` is a list of strings. |
| `autocomplete` | `options?` or `dynamic_options: true`, `value?`, `placeholder?` | Pick-or-create combobox with a suggestion list. |
| `hidden` | `value?` | Not rendered; rides along on POST. |

### `textarea`

`language` picks Ace highlighting - `yaml`, `toml`, `json`, `markdown`, `shell`, `scriptling` (plain text when unset); `rows` sets the editor height (default 6); `wrap` defaults to true (soft wrap); `wrap: false` keeps long lines on one line with horizontal scrolling. Without the editor the field degrades to a plain textarea, and the value is always submitted as a string however it was edited.

### `autocomplete`

Fixed `options` ship in the definition. With `dynamic_options: true` the client instead asks the form's own handler, GETting it with `_data=<field name>` before anything else, and that GET returns `{"options": [...]}` - fully dynamic, different per user and per load. Suggestions may be plain strings or `{key, text}` pairs, where the user picks by text and the form stores the key.

## The envelope

The POST's return value drives everything the client does next:

- **`ok`** - `{"status": "ok", "message"?, "refresh"?, "dialog"?}`: the message (default `Done.`) shows as a notification; `refresh` names the columns to re-fetch (`refresh: ["spaces"]`) or all of them (`refresh: true`); `dialog` is `{title, markdown}` which opens as an information popup after the toast, its markdown rendered server-side like every markdown payload.
- **`error`** - `{"status": "error", "message"?, "field_errors"?}`: the message notifies, and `field_errors` maps field names to messages painted on the form's inputs.

### After a successful submit

A plain form **resets to its initial values** - one entry can be added after another without retyping over the last. An `auto_submit: true` form is a filter: it has no submit button, fires on change, and **keeps its values**, folding them into the page's parameters so refreshed columns fetch with the new filters. A popup form closes cleanly on `ok`.

Popup forms are dirty-tracked like knot's own form dialogs: edits mark the form, and closing it (the close button or Esc) asks before discarding.

## Form popups

A [table action](../pages/#table-actions) with a `handler` opens a popup: the client GETs that handler's URL with the row key (`/<handler>?key=<row key>`), and a `{title?, fields, submit?, cancel?}` response renders as a form popup. Submit POSTs to the same handler with `key`; `error` keeps the popup open with `field_errors` painted on the inputs, `ok` closes it, notifies and refreshes. Dynamic autocompleters work inside popups; their `_data` fetches go to the popup's own handler. The fetch-time gate serves the popup handler only if the [layout names it](../pages/#popup-actions) - or it carries a `[[tool.knot.handlers]]` declaration.

## Where forms submit

A form column POSTs to its own handler URL, a popup to its handler with `key` - both are the ordinary [handler URLs](../pages/#the-dispatch-model) every plugin handler answers, so anything a form can do is also scriptable with curl or [`pluginFetch`](../html/).
