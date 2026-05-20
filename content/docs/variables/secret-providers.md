---
title: Secret Providers
weight: 30
---

{{< pro-badge >}} Secret providers let templates and server-side Scriptling runtimes fetch secrets from an external secret manager at resolve time instead of storing the value in the **knot** database.

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

Notes:

- The first argument to `secret` is the registered provider alias.
- Vault supports token authentication and AppRole authentication.
- 1Password Connect accepts either vault and item names or UUIDs.
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

Restart **knot** after updating the configuration.

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

If no field is supplied, **knot** uses the provider's `default_field`, which defaults to `value` for Vault.

### 1Password Connect

```yaml
environment:
  - API_KEY=${{ secret "op" "Engineering/API Service Key" "credential" }}
  - LOGIN_PASSWORD=${{ secret "op" "Engineering/App Login" }}
```

For 1Password Connect, the path is `vault/item`. If no field is supplied, **knot** defaults to `password`, then falls back to common built-in field names if available.

---

## Scriptling Usage

The same `[[server.secret_providers]]` configuration is also exposed to server-side Scriptling environments through `scriptling.secret`.

Available in:

- MCP tool scripts
- remote scripts, including startup and shutdown scripts

Not available in:

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
- When the TTL expires, **knot** fetches a fresh value from the upstream provider.

---

## Notes

- Secret providers are a **knot Pro** feature.
- Vault addresses must use `https://`.
- 1Password Connect supports both `http://` and `https://` addresses.
- Resolved secret values are not written to the database.
- Secret values are never logged.
