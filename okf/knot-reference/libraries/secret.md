---
description: Read the space owner's personal 1Password secrets from scripts running inside a space.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/reference/libraries/secret/
sources:
    - resource: https://getknot.dev/reference/libraries/secret/
status: stable
tags:
    - api
    - scripting
    - security
title: knot.secret
type: API Reference
---
# knot.secret

 The `knot.secret` library reads the space owner's [personal secrets](../../knot-docs/variables/personal-secrets.md) from 1Password, using the service account token stored on their profile. Secrets are read through the space's agent, so they are only available to scripts running inside a space.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Remote/space scripts (startup scripts), `knot run-script`, health check scripts | Available. Reads go through the space's agent and use the space owner's token. |
| Scriptling using Knot as a plugin, inside a space | Available, through the plugin and the space's agent. |
| MCP tool execution, event sink scripts, plugin handlers | Not available: `get()` raises an error. |
| External standalone, or anywhere outside a space | Not available: `get()` raises an error. |

A space whose template has **Disable Personal Secrets** turned on refuses every read. On Knot Core, `get()` reports that the server doesn't support personal secrets.

---

## Functions

| Function | Description |
|----------|-------------|
| `get(path, field="")` | Read a secret and return its value as a string |

### get

```python
get(path, field="")
```

- `path` (`str`): `vault/item`, with the vault and item given by name or ID, or a complete 1Password secret reference such as `op://vault/item/field`.
- `field` (`str`): The field to read; defaults to `password`. A field inside a section is written `section/field`. Leave it empty when `path` is an `op://` reference.

Raises an exception when no token is set on the owner's profile, the owner lacks the Use Personal Secrets permission, the template switches personal secrets off, or 1Password can't return the secret.

---

## Examples

```python
import knot.secret

password = knot.secret.get("Knot/Database")
username = knot.secret.get("Knot/Database", "username")
api_key = knot.secret.get("op://Knot/Stripe/API Keys/secret key")
```

Handle a missing secret:

```python
import knot.secret

try:
    token = knot.secret.get("Knot/Deploy", "token")
except Exception as e:
    print("no deploy token:", e)
```

The token itself is set in the Knot web interface; there is no function for it. See [Personal Secrets](../../knot-docs/variables/personal-secrets.md).
