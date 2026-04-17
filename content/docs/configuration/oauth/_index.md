---
title: OAuth Authentication
weight: 55
---

{{< pro-badge >}} **knot** supports OAuth authentication through external identity providers, allowing users to sign in with their existing GitHub, GitLab, Google, or Auth0 accounts — or any OpenID Connect compatible provider.

OAuth providers are configured in `knot.toml` using the `[[server.auth_providers]]` TOML array-of-tables. Multiple providers can be enabled simultaneously.

---

## Supported Providers

| Provider | `provider` value | Requirement |
| --- | --- | --- |
| GitHub | `github` | GitHub OAuth App with `user:email` scope |
| GitLab | `gitlab` | GitLab application with `read_user` scope |
| Google | `google` | Google Cloud project with OAuth 2.0 Web client |
| Auth0 | `auth0` | Auth0 application with `openid profile email` scopes |
| Generic OIDC | `oidc` | Any OpenID Connect compatible provider with a discovery endpoint |

---

## Prerequisites

- A valid **knot Pro** license
- OAuth application credentials from your chosen provider(s)
- Your **knot** server must be accessible at a public or internal URL (configured via `server.url`)

---

## GitHub Setup

### 1. Create a GitHub OAuth App

1. Go to **Settings** > **Developer settings** > **OAuth Apps** > **New OAuth App** (or visit [github.com/settings/developers](https://github.com/settings/developers)).
2. Fill in the application details:
   - **Application name** — A descriptive name (e.g., "Knot")
   - **Homepage URL** — Your **knot** server URL (e.g., `https://knot.example.com`)
   - **Authorization callback URL** — `{your-knot-url}/auth/github/callback` (e.g., `https://knot.example.com/auth/github/callback`)
3. Click **Register application**.
4. Note the **Client ID**.
5. Click **Generate a new client secret** and note the value (it is only shown once).

### 2. Configure knot

Add the following to your `knot.toml`:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "github"
client_id = "your-github-client-id"
client_secret = "your-github-client-secret"
```

Restart **knot** to apply the configuration.

---

## GitLab Setup

### 1. Create a GitLab Application

1. Go to **Preferences** > **Applications** (or visit [gitlab.com/-/user_settings/applications](https://gitlab.com/-/user_settings/applications)).
2. Fill in the application details:
   - **Name** — A descriptive name (e.g., "Knot")
   - **Redirect URI** — `{your-knot-url}/auth/gitlab/callback` (e.g., `https://knot.example.com/auth/gitlab/callback`)
   - **Scopes** — Select `read_user`
3. Click **Save application**.
4. Note the **Application ID** and **Secret**.

### 2. Configure knot

Add the following to your `knot.toml`:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "gitlab"
client_id = "your-gitlab-application-id"
client_secret = "your-gitlab-secret"
```

Restart **knot** to apply the configuration.

### Self-Hosted GitLab

To use a self-hosted GitLab instance, set the `base_url` field to your GitLab server URL:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "gitlab"
base_url = "https://gitlab.example.com"
client_id = "your-gitlab-application-id"
client_secret = "your-gitlab-secret"
```

When `base_url` is set, all OAuth and API requests are directed to your self-hosted instance instead of `gitlab.com`.

---

## Google Setup

### 1. Create a Google OAuth Client

1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project (or select an existing one).
3. Navigate to **APIs & Services** > **Credentials**.
4. Click **Create Credentials** > **OAuth client ID**.
5. Configure the consent screen if prompted.
6. Set the application type to **Web application**.
7. Add an **Authorized redirect URI**: `{your-knot-url}/auth/google/callback` (e.g., `https://knot.example.com/auth/google/callback`)
8. Click **Create** and note the **Client ID** and **Client Secret**.

### 2. Configure knot

Add the following to your `knot.toml`:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "google"
client_id = "your-google-client-id.apps.googleusercontent.com"
client_secret = "your-google-client-secret"
```

Restart **knot** to apply the configuration.

---

## Auth0 Setup

### 1. Create an Auth0 Application

1. Go to the [Auth0 Dashboard](https://manage.auth0.com/) and select your tenant.
2. Navigate to **Applications** > **Applications** > **Create Application**.
3. Choose **Regular Web Application** and click **Create**.
4. Go to the **Settings** tab and note the **Domain** (e.g., `your-tenant.us.auth0.com`), **Client ID**, and **Client Secret**.
5. In **Allowed Callback URLs**, add: `{your-knot-url}/auth/auth0/callback` (e.g., `https://knot.example.com/auth/auth0/callback`)
6. In **Allowed Logout URLs**, add: `{your-knot-url}` (e.g., `https://knot.example.com`)
7. Click **Save Changes**.

### 2. Configure knot

Add the following to your `knot.toml`:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "auth0"
base_url = "https://your-tenant.us.auth0.com"
client_id = "your-auth0-client-id"
client_secret = "your-auth0-client-secret"
```

The `base_url` is your Auth0 tenant domain. It can be the Auth0 domain (e.g., `your-tenant.us.auth0.com`) or a custom domain.

Restart **knot** to apply the configuration.

---

## Generic OIDC Setup

The generic OIDC provider supports any OpenID Connect compatible identity provider (Okta, Keycloak, Azure AD, Dex, and others). It uses OIDC discovery to automatically configure endpoints.

Multiple OIDC providers can be configured by adding separate `[[server.auth_providers]]` entries with different `name` values.

### 1. Configure your Identity Provider

Create an OAuth 2.0 / OpenID Connect client in your identity provider with:

- **Redirect URI** — `{your-knot-url}/auth/{name}/callback` where `{name}` is the `name` you configure below (e.g., `https://knot.example.com/auth/okta/callback`)
- **Scopes** — `openid`, `profile`, `email`
- **Response type** — `code` (Authorization Code flow)

Note the **Client ID**, **Client Secret**, and the **discovery URL** (typically `https://your-idp.example.com/.well-known/openid-configuration`).

### 2. Configure knot

Add the following to your `knot.toml`:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "oidc"
name = "okta"
display_name = "Okta"
discovery_url = "https://your-idp.example.com/.well-known/openid-configuration"
client_id = "your-oidc-client-id"
client_secret = "your-oidc-client-secret"
```

The `name` field is a unique slug used in URLs (e.g., `/auth/okta/callback`). The `display_name` is shown in the UI and is optional — it defaults to the capitalized `name`.

On startup, **knot** fetches the discovery document to configure the authorization, token, and userinfo endpoints automatically.

Restart **knot** to apply the configuration.

### Example: Multiple OIDC Providers

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "oidc"
name = "okta"
display_name = "Okta"
discovery_url = "https://your-org.okta.com/.well-known/openid-configuration"
client_id = "okta-client-id"
client_secret = "okta-client-secret"
allowed_domains = ["yourcompany.com"]

[[server.auth_providers]]
provider = "oidc"
name = "keycloak"
display_name = "Keycloak"
discovery_url = "https://keycloak.example.com/realms/your-realm/.well-known/openid-configuration"
client_id = "knot-client"
client_secret = "keycloak-secret"
```

---

## Full Configuration Reference

Each provider is defined as a `[[server.auth_providers]]` entry with the following fields:

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `provider` | string | Yes | The provider type: `github`, `gitlab`, `google`, `auth0`, or `oidc` |
| `name` | string | Yes for `oidc` | Unique slug for OIDC providers (used in URLs and display) |
| `display_name` | string | No | Display name in the UI (OIDC only; defaults to capitalized `name`) |
| `client_id` | string | Yes | OAuth client ID from the provider |
| `client_secret` | string | Yes | OAuth client secret from the provider |
| `base_url` | string | No | Custom base URL (required for Auth0 tenant domain; defaults to `https://gitlab.com` for GitLab) |
| `discovery_url` | string | Yes for `oidc` | OIDC discovery document URL (e.g., `/.well-known/openid-configuration`) |
| `allowed_domains` | string[] | No | Restrict login to users with email addresses in these domains |
| `auto_create_users` | bool | No | Automatically create a **knot** user account on first login |
| `default_roles` | string[] | No | Role names assigned to auto-created users |
| `default_groups` | string[] | No | Group names assigned to auto-created users |

### Example: Multiple Providers with Auto-Provisioning

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "github"
client_id = "Iv1.example123"
client_secret = "ghp_example_secret"
auto_create_users = true
default_roles = ["User"]
default_groups = ["Developers"]

[[server.auth_providers]]
provider = "gitlab"
client_id = "your-gitlab-application-id"
client_secret = "your-gitlab-secret"
# base_url = "https://gitlab.example.com"  # Self-hosted GitLab
auto_create_users = true
default_roles = ["User"]
default_groups = ["Developers"]

[[server.auth_providers]]
provider = "google"
client_id = "123456789.example.apps.googleusercontent.com"
client_secret = "GOCSPX-example_secret"
allowed_domains = ["yourcompany.com"]
auto_create_users = true
default_roles = ["User"]
default_groups = ["Developers"]

[[server.auth_providers]]
provider = "auth0"
base_url = "https://your-tenant.us.auth0.com"
client_id = "your-auth0-client-id"
client_secret = "your-auth0-client-secret"
auto_create_users = true
default_roles = ["User"]
default_groups = ["Developers"]

[[server.auth_providers]]
provider = "oidc"
name = "keycloak"
display_name = "Keycloak"
discovery_url = "https://keycloak.example.com/realms/myrealm/.well-known/openid-configuration"
client_id = "knot-client"
client_secret = "your-keycloak-secret"
auto_create_users = true
default_roles = ["User"]
default_groups = ["Developers"]
```

---

## User Experience

When OAuth providers are configured:

- **Sign-in buttons** for each enabled provider appear on the **knot** login page alongside the standard email/password form.
- On first login via OAuth, **knot** either matches the user by email address or creates a new account (if `auto_create_users` is enabled).
- Users can **link** and **unlink** OAuth providers from their profile settings.
- Users created via OAuth are prompted to set a password for CLI access.

### Domain Restrictions

When `allowed_domains` is set, only users with an email address matching one of the listed domains can authenticate. For GitHub, this checks the user's primary verified email. For GitLab, it checks the email returned by the user API. For Google, Auth0, and OIDC providers, it checks the email returned by the userinfo endpoint.

---

## Callback URLs

The OAuth callback URLs follow a consistent pattern based on your configured `server.url`:

| Provider | Callback URL |
| --- | --- |
| GitHub | `{server.url}/auth/github/callback` |
| GitLab | `{server.url}/auth/gitlab/callback` |
| Google | `{server.url}/auth/google/callback` |
| Auth0 | `{server.url}/auth/auth0/callback` |
| Generic OIDC | `{server.url}/auth/{name}/callback` |

Ensure these URLs are registered as authorized redirect URIs in your provider's application settings.
