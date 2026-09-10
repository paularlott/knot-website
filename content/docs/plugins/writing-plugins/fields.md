---
title: Fields
description: Template custom fields backed by plugin field handlers.
weight: 30
---

Template **custom fields** let you collect per-space values when a space is created or edited. They are defined on the template (name, description, type), stored as plain strings, and exposed to provisioning as variables. Plugins can back the autocomplete type by serving the suggestion list.

## The field itself

A template's custom field has a **name**, a **description** (its label on the space form), and a **type**:

- `text` (default) - plain single-line input.
- `masked` - the value is hidden while typing (a browser password control with `autocomplete="new-password"`).
- `number` - digit-validated input; stored as a string.
- `bool` - the styled true/false toggle; the value is the string `"true"` or `"false"`, prefilled from the field's default.
- `textarea` - a code editor for multi-line values, with a configurable **language**: text, scriptling, yaml, toml, json, markdown or shell. Scriptling gets the same completions as the script editors.
- `select` - a dropdown. Options come from one of exactly two sources: a plugin field handler (refreshed as the form loads; picking stores the option's key when suggestions are key/text pairs) or a manual list declared right on the field (one option per line in the wrench dialog, values stored verbatim).
- `autocomplete` - a searchable combobox taking the same two sources as select: a plugin field handler's suggestions, or the manual list. Picking (or typing an option's exact key or text) stores that option — the field only ever holds a valid option, never free text.

Values are stored as strings regardless of type. Admins set a field's type, language and handler by opening the wrench next to the field in the template editor; each row's badge shows its type. Type, language and handler are validated when the template is saved: a type outside this list is rejected rather than silently rendered as a text input.

**Required.** A field can be marked required (a toggle in the wrench dialog, default off): a required field cannot be left blank when creating or editing a space - the form marks it and refuses to save, and the space API rejects absent, empty or whitespace-only values with `missing required custom field(s)`. A default value can satisfy the requirement, and a `bool` field is never blank.

**Valid options.** A `select` or `autocomplete` value is validated server-side when a space is created or updated: it must be one of the field's option keys, or blank when the field is not required — the form restricts picking, the API for every caller, rejecting with `invalid value for custom field(s)`. Handler-backed fields dispatch their handler as the requesting user at submit time, so dynamic option lists gate exactly what they served. A value carried over unchanged on edit is not re-validated, so an edit is never blocked by an option list that has moved on since the value was set. A template default outside a manual option list is rejected when the template is saved (a handler-backed default is validated at create time instead, when its options are known).

**`masked` is presentation-only.** The name says what it does: it hides the value while typing - an over-the-shoulder affordance, nothing more. The value is still stored as a plain string on the space, is returned by the space API and appears in editable forms exactly like a `text` field: no encryption, no redaction. It is not a secret store - anything that must not be readable should use [secret providers](../../variables/secret-providers/) instead.

## Field handlers

A field handler is a function a plugin declares for exactly this purpose:

```python
# [[tool.knot.field_handlers]]
# label = "Environments (demo plugin)"      # optional, defaults to the function name
# handler = "field_environment"
# ///

def field_environment(request):
    return {"options": [
        {"key": "dev", "text": "development"},
        {"key": "prod", "text": "production"},
    ]}
```

The `handler` function name is the handler's identity; a template binds to its qualified form `plugin.<name>.<handler>`. Suggestions are **key -> text**: the user picks by text, the space stores the **key** as the variable's value (a plain string option means key and text are the same, so simple lists stay simple).

**When the handler runs.** Whenever a space create/edit form renders a bound field - the completer fetches eagerly on load, so even a reload resolves a stored key back to its display text. It runs as the requesting user through the permission-checked loopback, called `handler(request)` - `request["params"]` carries `_data` (the qualified handler id) and `query` (when given), and `request["user"]` the requesting user as data ([the request argument](../scriptling/#the-request-argument)), so suggestions can adapt to who is asking. Options can therefore be fully dynamic: return whatever `knot.*` yields *right now*, different per user and per load.

**Who may invoke it.** The options endpoint requires the Use Spaces permission (space forms drive the fetches). A field handler can declare an additional gate, narrowing who may invoke it - useful when the suggestions expose data not every space user should see:

```python
# [[tool.knot.field_handlers]]
# label = "Environments"
# handler = "field_environment"
# permission = "pick"      # optional; must be declared in [tool.knot] permissions
```

The `demo-scriptling` example declares a working `field_environment`. For a full handler against real live data, see the [scriptling](../scriptling/#fields) walkthrough.
