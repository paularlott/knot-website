---
title: Fields
description: Template custom fields backed by plugin field handlers.
weight: 30
---

Template **custom fields** let you collect per-space values when a space is created or edited. They are defined on the template (name, description, type), stored as plain strings, and exposed to provisioning as variables. Plugins can back the autocomplete type by serving the suggestion list.

## The field itself

A template's custom field has a **name**, a **description** (its label on the space form), and a **type**:

- `text` (default) - plain single-line input.
- `password` - masked input (`autocomplete="new-password"`).
- `number` - digit-validated input; stored as a string.
- `textarea` - a code editor for multi-line values, with a configurable **language**: text, scriptling, yaml, toml, json, markdown or shell. Scriptling gets the same completions as the script editors.
- `autocomplete` - a pick-or-create combobox whose suggestions come from a plugin field handler.

Values are stored as strings regardless of type. Admins set a field's type, language and handler by opening the wrench next to the field in the template editor; each row's badge shows its type.

## Field handlers

A field handler is a function a plugin declares for exactly this purpose:

```python
# [[tool.knot.field_handlers]]
# label = "Environments (demo plugin)"      # optional, defaults to the function name
# handler = "field_environment"
# ///

def field_environment():
    return {"options": [
        {"key": "dev", "text": "development"},
        {"key": "prod", "text": "production"},
    ]}
```

The `handler` function name is the handler's identity; a template binds to its qualified form `plugin.<name>.<handler>`. Suggestions are **key -> text**: the user picks by text, the space stores the **key** as the variable's value (a plain string option means key and text are the same, so simple lists stay simple).

**When the handler runs.** Whenever a space create/edit form renders a bound field - the completer fetches eagerly on load, so even a reload resolves a stored key back to its display text. It runs as the requesting user through the permission-checked loopback, receiving `params` with `_data` (the qualified handler id) and `query` (when given). Options can therefore be fully dynamic: return whatever `knot.*` yields *right now*, different per user and per load.

The `demo-scriptling` example declares a working `field_environment`. For a full handler against real live data, see the [scriptling](../scriptling/#fields) walkthrough.
