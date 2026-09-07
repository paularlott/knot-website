---
title: knot.identity
description: The requesting user for module code - plugin libraries and lib scripts that can't see the user global.
type: API Reference
tags: [api, scripting, plugins]
weight: 25
---

The `knot.identity` library carries the requesting user's identity into **module code** — a plugin's exported scriptling libraries (`libs/*.py`) and loaded lib scripts. The `user` global is bound on the calling program's scope, which imports can't see; this library returns the same instance, re-bound on every dispatch, so it always answers with the current user.

```python
# libs/report.py — a plugin's exported library
import knot.identity

def export_report():
    if not knot.identity.user().has_permission("plugin.metrics.export"):
        raise Exception("plugin.metrics.export not granted")
    return {"rows": []}
```

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Plugin handler environments | Available; re-registered per lease, so pooled environments carry the current requesting user. |
| MCP server (user-created tools, event sinks) | Available; bound per execution. |
| Agent / spaces | Not available — the agent environment binds no user identity. |

---

## Functions

| Function | Description |
|----------|-------------|
| `user()` | The `User` instance the `user` global holds: `id`, `name`, `is_admin`, `groups`, `permissions` (stable keys), `plugin_permissions` (qualified grants), with `has_permission(key)` and `in_group(name)` methods. |

---

## See also

- [The dispatch globals](../../docs/plugins/writing-plugins/scriptling/#the-dispatch-globals) — the `user` global handler code reads directly.
- [Plugin exports in user tools](../../docs/plugins/writing-plugins/mcp-tools/#plugin-exports-in-user-tools) — why exported code self-gates.
