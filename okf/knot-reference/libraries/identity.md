---
description: The authoritative requesting-user surface for plugin and tool code - a real User object with permission checks, over the gated loopback.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/libraries/identity/
sources:
    - resource: https://getknot.dev/reference/libraries/identity/
status: stable
tags:
    - api
    - scripting
    - plugins
title: knot.identity
type: API Reference
---
# knot.identity

The `knot.identity` library returns the requesting user as a real `User` object — with `has_permission` / `in_group` — re-bound on every dispatch. It is the **authoritative** identity surface: use it for any permission decision.

It matters most for **module code** — a plugin's exported scriptling libraries (`libs/*.py`) and loaded lib scripts. A plugin handler receives the caller as data in its `request["user"]` argument, but a library is a module: it never sees the handler's `request`, so it reads `knot.identity` directly. (`request["user"]` is an inert snapshot for branching; `knot.identity` is the authority that rides the gated loopback, where the admin role passes every check.) In the MCP-tool environment the same library is how a user tool asks who it runs as.

```python
# libs/report.py — a plugin's exported library, imported by another plugin
import knot.identity

def export_report():
    # A composing plugin imports this ungated, so the gate lives here.
    if not knot.identity.user().has_permission("plugin.metrics.export"):
        raise Exception("plugin.metrics.export not granted")
    return {"rows": []}
```

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Plugin handler environments | Available; re-registered per lease, so pooled environments carry the current requesting user. Handlers also get `request["user"]` data; `knot.identity` is the authority for checks. |
| MCP server (user-created tools, event sinks) | Available; bound per execution. |
| Agent / spaces | Not available — the agent environment binds no user identity. |

---

## Functions

| Function | Description |
|----------|-------------|
| `user()` | The requesting `User`: `id`, `name`, `is_admin`, `groups`, `permissions` (stable keys), `plugin_permissions` (qualified grants), with `has_permission(key)` and `in_group(name)` methods. `has_permission`'s argument picks the check: an integer is a built-in permission id (the `knot.permission` constants), a `"plugin."`-prefixed string a qualified grant, any other string a built-in's stable key; the admin role passes every check. |

---

## See also

- [The request argument](../../knot-docs/plugins/writing-plugins/scriptling.md#the-request-argument) — how a handler receives the caller as `request["user"]` data.
- [The trust boundary: import vs call](../../knot-docs/plugins/writing-plugins/mcp-tools.md#the-trust-boundary-import-vs-call) — why exported code self-gates for cross-plugin composition.
