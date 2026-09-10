---
title: knot.token
description: Manage API tokens — mint scoped keys, list them, revoke them.
type: API Reference
tags: [security, authentication, api]
weight: 46
---

The `knot.token` library manages the current user's API tokens: mint keys for machines and pipelines (optionally narrowed by [scopes](../../api-tokens/#scoping-a-token)), list existing tokens, and revoke them.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Not available. |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List the current user's API tokens |
| `create(name, scopes=None)` | Create an API token and return its value |
| `delete(token_id)` | Delete a token by id (its value), revoking it immediately |

---

### list()

List the current user's API tokens.

**Returns:** `list` of dicts, each containing:
- `id` (string): The token's value — the bearer key itself
- `name` (string): The token's name
- `expires_after` (string): Expiry timestamp — any use resets the two week clock
- `scopes` (list): The token's scope list, empty for full access

---

### create(name, scopes=None)

Create an API token for the current user.

**Parameters:**
- `name` (string): Name identifying the token
- `scopes` (list, optional): Narrows the token to endpoint groups — `"methods"` (`/api/methods*`), `"mcp"` (`/mcp`) and `"tunnels"` (`/tunnel/*` and `/api/tunnels*`: create, list and delete tunnels only). Empty or omitted means full access.

**Returns:** `string` - The new token's value (the bearer key) — pass it to clients, e.g. [`space.tunnel_start(..., token=...)`](../space/#tunnel_startspace-protocol-port-name-server-token) or a pipeline's `knot tunnel --token`.

---

### delete(token_id)

Delete an API token, revoking it immediately.

**Parameters:**
- `token_id` (string): The token's value, from `create` or `list`

**Returns:** `bool` - `True` on success

---

## Examples

```python
import knot.token as token

# A tunnels-only key for a machine that should do nothing but expose a port
key = token.create("pipeline-tunnel", scopes=["tunnels"])
print(key)  # the bearer key — the only time to copy it is now or via list

# Revoke it when the pipeline retires
token.delete(key)
```
