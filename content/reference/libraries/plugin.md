---
title: knot.plugin
description: Call plugins' declared handlers as the requesting user - in-process between plugins, over the authenticated loopback from user-created tools.
type: API Reference
tags: [api, scripting, plugins]
weight: 24
---

The `knot.plugin` library calls a plugin's **declared** handlers — the `[[tool.knot.handlers]]` contract the browser's `pluginFetch` uses — as the requesting user. One call contract, two transports: the environment decides which, and both behave identically — same signature (`method` kwarg included), same name validation, declared-handlers-only, the declaration's gate enforced before any plugin code runs. Only the transport differs.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Plugin handler environments (pages, MCP tools plugins expose, field handlers) | In-process bridge between plugins of the same trust domain. The declaration's gate is checked at the call boundary. |
| MCP server (user-created tools, event sinks) | The call rides the in-process loopback — the same authenticated transport the other `knot.*` libraries use — through the real web dispatch, so gates apply exactly as for a browser fetch. |
| Agent / spaces | Not available. |

---

## Functions

| Function | Description |
|----------|-------------|
| `call(plugin, handler, params?)` | Call a plugin's declared handler as the requesting user. `params` become the query string (GET, the default). Returns the handler's JSON answer as a dict. |
| `call(plugin, handler, params, method="POST")` | POST variant: `params` travel as a JSON body, for handlers that branch on `request.method`. |

Errors raise: `permission denied` when the requesting user fails the declaration's gate, `not addressable` for a handler without a `[[tool.knot.handlers]]` declaration (or an unknown plugin), and the handler's own failure otherwise. The called handler runs with the full dispatch context — `params`, `request` and the `user` global — so it can self-check exactly as a page handler does.

```python
import knot.plugin as kp

result = kp.call("metrics", "export_all", {"range": "1h"})
# Submit-style handler (branches on request.method):
result = kp.call("metrics", "submit", {"range": "1h"}, method="POST")
```

---

## See also

- [MCP Tools — calling plugins from tools](../../docs/plugins/writing-plugins/mcp-tools/) — the trust boundary the two transports draw.
- [Plugin Pages](../../docs/plugins/writing-plugins/pages/) — the handler-URL and gate contract underneath every call.
