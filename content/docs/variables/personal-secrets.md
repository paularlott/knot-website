---
title: Personal Secrets
description: Read your own 1Password secrets inside your spaces, using a service account token stored on your profile.
type: Guide
tags: [variables, security]
weight: 45
---

{{< pro-badge >}} Personal secrets let each user read **their own** secrets from 1Password inside their spaces. You store a 1Password service account token on your profile in the web interface, and your spaces read secrets with `knot secret get` or `knot.secret.get()`.

Personal secrets are separate from the server's [secret providers](../secret-providers/):

| | Secret providers | Personal secrets |
| --- | --- | --- |
| Configured by | Administrator, in `knot.toml` | Each user, on their profile |
| Credentials | Server-wide | The user's own service account token |
| Used from | Templates and server-side scripts | Inside spaces only, through the space's agent |
| In templates and custom fields | Yes, `${{ secret ... }}` | No |

Personal secrets are read only inside a space: the space's agent asks the server over its own connection, so the server knows which space is asking and applies that space's template. There is no API endpoint for reading them, and they are never rendered into templates or custom fields, so their values never appear in a space's job definition.

---

## Before You Start

- An administrator must give you the **Use Personal Secrets** permission (in the *Space Operations* group). The Admin role includes it.
- You need a 1Password account that can create [service accounts](https://developer.1password.com/docs/service-accounts/).
- Service accounts can't be given access to your built-in **Personal**, **Private** or **Employee** vault, or the default **Shared** vault. Create a vault for the secrets you want to use from Knot, and give the service account read access to that vault.

---

## Set Your Token

1. Create a 1Password service account with read access to your vault. Copy its token, which starts with `ops_`.
2. In Knot, open your **Profile**. Under **Personal Secrets**, paste the token and click **Save**. Leaving the field blank keeps the stored token; **Clear Token** removes it.

The token is stored encrypted and can't be read back — your profile only shows whether one is set. Setting a new token replaces the old one.

The token can only be set or cleared in the web interface: not with an API token, from a space or from a script.

---

## Reading Secrets

A secret is addressed by its 1Password secret reference, `op://vault/item/field`, with a field inside a section written `op://vault/item/section/field`.

### CLI

`knot secret` is part of the agent's `knot` command inside your spaces, and acts as the space owner.

```sh
knot secret get op://Knot/Database/username
knot secret get "op://Knot/Stripe/API Keys/secret key"
```

The value is printed to stdout. Use `--no-newline` to leave out the trailing newline:

```sh
export DB_PASSWORD="$(knot secret get op://Knot/Database/password)"
```

### Scriptling

```python
import knot.secret

username = knot.secret.get("op://Knot/Database/username")
password = knot.secret.get("op://Knot/Database/password")
api_key = knot.secret.get("op://Knot/Stripe/API Keys/secret key")
```

`knot.secret.get()` works in scripts that run inside a space: scripts run by the agent, such as `knot run-script`, and Scriptling using Knot as a plugin inside the space. It reads the space owner's secrets. Anywhere else, including server-side scripts such as MCP tools and event sinks, it raises an error.

---

## Switching Them Off for a Template

An administrator can turn on **Disable Personal Secrets** in a template's features to refuse personal secrets in every space created from it. This covers only the token on your profile; 1Password tools you run in the space yourself aren't affected.

A space can also switch them off for itself, or keep only those under chosen vaults or items, with its [restrictions](/docs/spaces/restrictions/#limit-personal-secrets-by-path).

---

## Shared Spaces

Inside a space, `knot secret get` runs as the **space owner**. Anyone you share a space with can run it there and read your secrets. A secret a script writes to a file or environment variable is also readable by anyone with access to the space.

Only share spaces that use personal secrets with people you trust with those secrets.

---

## Caching and Rate Limits

- Values are cached on the server for 5 minutes, per user and per secret. Changing your token clears your cached values.
- 1Password limits how many requests a service account can make per hour and per day. When the limit is reached, Knot returns an error and you can try again later.

---

## Auditing

Knot writes an audit event when a token is set or cleared, and for every secret read, including failed ones. Audit events record the vault, item and field. Secret values and tokens are never logged.

---

## Notes

- Personal secrets are a **Knot Pro** feature. On Knot Core, `knot.secret.get()` reports that the server doesn't support personal secrets.
- Only the space owner's token is ever used. The server's secret providers can't be reached through `knot secret get` or `knot.secret.get()`.
- Reading personal secrets needs agents from Knot v0.39.0 or later; an older server reports that it doesn't support them.
