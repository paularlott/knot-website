---
title: Secret Providers
description: Secret providers fetch secrets from external managers like Vault and 1Password at template resolve time.
type: Guide
tags: [variables, security]
weight: 40
---

{{< pro-badge >}} Secret providers let templates and server-side Scriptling runtimes fetch secrets from an external secret manager at resolve time instead of storing the value in the Knot database.

Secret provider functions only run during server-side variable resolution, including:

- container job rendering
- volume definition rendering
- CSI volume definition rendering
- MCP tool scripts
- remote/startup/shutdown scripts running through the Knot server

---

## Supported Providers

The current implementation supports the following providers:

| Provider          | `provider` value | Alias example           | Path format        | Default field | Template usage                                                  |
| ----------------- | ---------------- | ----------------------- | ------------------ | ------------- | --------------------------------------------------------------- |
| HashiCorp Vault   | `vault`          | `vault` or `prod_vault` | `secret/data/path` | `value`       | `${{ secret "vault" "secret/data/prod/database" "password" }}`  |
| 1Password Connect | `onepassword`    | `op`                    | `vault/item`       | `password`    | `${{ secret "op" "Engineering/API Service Key" "credential" }}` |
| 1Password service account | `onepassword` | `op`               | `vault/item`       | `password`    | `${{ secret "op" "Engineering/API Service Key" "credential" }}` |

Notes:

- The first argument to `secret` is the registered provider alias.
- Vault supports token authentication and AppRole authentication.
- 1Password accepts either vault and item names or IDs, through Connect or a service account.
- For 1Password paths, the first path segment is the vault and the remainder is the item reference.

---

## Configuration

Configure one or more providers in `knot.toml` using `[[server.secret_providers]]`.

### Vault

```toml {filename=knot.toml}
[[server.secret_providers]]
provider = "vault"
address = "https://vault.internal:8200"
token = "hvs.your-token"
# alias = "vault"
# cache_ttl = "5m"
# namespace = "admin"
# kv_version = 2
# default_field = "value"
```

### Vault with AppRole

Vault AppRole authentication can be used instead of a static token:

```toml {filename=knot.toml}
[[server.secret_providers]]
provider = "vault"
address = "https://vault.internal:8200"
app_role_id = "role-id"
app_role_secret = "secret-id"
# alias = "prod_vault"
# cache_ttl = "10m"
```

### 1Password Connect

```toml {filename=knot.toml}
[[server.secret_providers]]
provider = "onepassword"
alias = "op"
address = "http://onepassword-connect:8080"
token = "your-connect-token"
# cache_ttl = "5m"
# default_field = "password"
```

### 1Password Service Account

A [1Password service account](https://developer.1password.com/docs/service-accounts/) reads secrets without running a Connect server. Give `service_account_token` instead of `address` and `token`:

```toml {filename=knot.toml}
[[server.secret_providers]]
provider = "onepassword"
alias = "op"
service_account_token = "ops_your-service-account-token"
# cache_ttl = "5m"
# default_field = "password"
```

Templates and scripts use the same paths and fields with either mode, so you can move a provider from Connect to a service account without changing them. A provider uses one mode: giving both `service_account_token` and `address` or `token` is an error.

The service account can only read the vaults it was given when it was created. It can't be given your built-in Personal, Private or Employee vault, or the default Shared vault. 1Password also limits how many requests a service account makes; Knot's cache keeps repeated reads from counting against it.

Restart Knot after updating the configuration.

---

## Template Usage

Use the built-in `secret` template function:

```yaml
environment:
  - DB_PASSWORD=${{ secret "vault" "secret/data/prod/database" "password" }}
  - API_KEY=${{ secret "op" "Engineering/API Service Key" "credential" }}
```

### Vault

```yaml
environment:
  - DB_PASSWORD=${{ secret "vault" "secret/data/prod/database" "password" }}
  - API_TOKEN=${{ secret "vault" "secret/data/prod/api" }}
```

If no field is supplied, Knot uses the provider's `default_field`, which defaults to `value` for Vault.

### 1Password Connect

```yaml
environment:
  - API_KEY=${{ secret "op" "Engineering/API Service Key" "credential" }}
  - LOGIN_PASSWORD=${{ secret "op" "Engineering/App Login" }}
```

For 1Password Connect, the path is `vault/item`. If no field is supplied, Knot defaults to `password`, then falls back to common built-in field names if available.

---

## Scriptling Usage

The same `[[server.secret_providers]]` configuration is also exposed to server-side Scriptling environments through `scriptling.secret`.

Available in:

- Server-side scripts (MCP tool scripts, event sinks)

Not available in:

- agent-side scripts (the agent has no secret providers)
- standalone external `scriptling` runs unless you configure that host separately

```python
import scriptling.secret as secret

db_password = secret.get("vault", "secret/data/prod/database", "password")
api_key = secret.get("op", "Engineering/API Service Key", "credential")
```

### Multiple Provider Instances

Multiple provider instances can be configured with different aliases:

```toml {filename=knot.toml}
[[server.secret_providers]]
provider = "vault"
alias = "prod_vault"
address = "https://vault-prod.internal:8200"
token = "hvs.prod-token"

[[server.secret_providers]]
provider = "vault"
alias = "staging_vault"
address = "https://vault-staging.internal:8200"
token = "hvs.staging-token"
```

```yaml
environment:
  - PROD_DB=${{ secret "prod_vault" "secret/data/prod/database" "password" }}
  - STAGING_DB=${{ secret "staging_vault" "secret/data/staging/database" "password" }}
```

---

## Cache Behavior

Secret values are cached per provider alias, path, and field.

- The default cache TTL is 5 minutes.
- `cache_ttl` can be set per provider using any Go duration string such as `30s`, `5m`, or `15m`.
- When the TTL expires, Knot fetches a fresh value from the upstream provider.

---

## Notes

- Secret providers are a **knot Pro** feature.
- Vault addresses support both `http://` (e.g. a local dev Vault) and `https://` — use `insecure_skip_tls = true` to skip certificate verification for self-signed certificates.
- 1Password Connect supports both `http://` and `https://` addresses.
- A 1Password service account needs no address; Knot connects to 1Password directly.
- Resolved secret values are not written to the database.
- Secret values are never logged.
- To let users read their own 1Password secrets at runtime with their own token, see [Personal Secrets](../personal-secrets/).
