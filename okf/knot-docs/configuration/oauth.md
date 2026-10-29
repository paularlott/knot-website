---
description: Sign in with GitHub, GitLab, Google, Microsoft, Auth0, or any OIDC identity provider.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/configuration/oauth/
sources:
    - resource: https://getknot.dev/docs/configuration/oauth/
status: stable
tags:
    - security
    - authentication
    - configuration
title: OAuth Authentication
type: Overview
---
# OAuth Authentication

 Knot supports OAuth authentication through external identity providers, allowing users to sign in with their existing GitHub, GitLab, Google, Microsoft, or Auth0 accounts — or any OpenID Connect compatible provider.

OAuth providers are configured in `knot.toml` using the `[[server.auth_providers]]` TOML array-of-tables. Multiple providers can be enabled simultaneously.

---

## Supported Providers

| Provider | `provider` value | Requirement |
| --- | --- | --- |
| GitHub | `github` | GitHub OAuth App with `user:email` scope |
| GitLab | `gitlab` | GitLab application with `read_user` scope |
| Google | `google` | Google Cloud project with OAuth 2.0 Web client |
| Microsoft | `microsoft` | Microsoft Entra ID app registration |
| Auth0 | `auth0` | Auth0 application with `openid profile email` scopes |
| Generic OIDC | `oidc` | Any OpenID Connect compatible provider with a discovery endpoint |

---

## Prerequisites

- **knot Pro** (free for up to 2 users; a license is only needed beyond that)
- OAuth application credentials from your chosen provider(s)
- Your Knot server must be accessible at a public or internal URL (configured via `server.url`)

Knot signs in with the authorization code flow and PKCE (S256) for every provider, as OAuth 2.1 and current best practice require, so providers that insist on PKCE work without extra setup. Register knot as a confidential (web) client with a client secret; knot sends the secret in the token request body (`client_secret_post`).

---

## GitHub Setup

### 1. Create a GitHub OAuth App

1. Go to **Settings** > **Developer settings** > **OAuth Apps** > **New OAuth App** (or visit [github.com/settings/developers](https://github.com/settings/developers)).
2. Fill in the application details:
   - **Application name** — A descriptive name (e.g., "Knot")
   - **Homepage URL** — Your Knot server URL (e.g., `https://knot.example.com`)
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

Restart Knot to apply the configuration.
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

Restart Knot to apply the configuration.

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

Restart Knot to apply the configuration.


---

## Microsoft Setup

The Microsoft provider signs users in with Microsoft Entra ID (formerly Azure AD). Knot knows each user by their tenant ID and object ID, never by email, and only the tenants you allow can sign in. Use it rather than the generic OIDC provider for Entra.

### 1. Register an application

1. In the [Microsoft Entra admin center](https://entra.microsoft.com/), go to **Identity** > **Applications** > **App registrations** > **New registration**.
2. Choose who can use it: **Single tenant** for your own organization, or **Multitenant** if users from other organizations will sign in.
3. Under **Redirect URI**, choose **Web** and enter `{your-knot-url}/auth/microsoft/callback` (e.g., `https://knot.example.com/auth/microsoft/callback`).
4. Click **Register**, and note the **Application (client) ID** and **Directory (tenant) ID**.
5. Under **Certificates & secrets**, create a **New client secret** and note its value.

### 2. Configure knot

For your own organization, set `tenant` to its directory (tenant) ID:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "microsoft"
tenant = "11111111-2222-3333-4444-555555555555"
client_id = "your-application-client-id"
client_secret = "your-client-secret"
```

For a multitenant application, leave `tenant` unset (it defaults to `organizations`) and list the tenant IDs allowed to sign in. `allowed_tenants` is required unless `tenant` is a tenant ID:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "microsoft"
client_id = "your-application-client-id"
client_secret = "your-client-secret"
allowed_tenants = ["11111111-2222-3333-4444-555555555555", "99999999-8888-7777-6666-555555555555"]
```

Restart Knot to apply the configuration.

Entra's `email` claim is set by each tenant's administrators, so Knot doesn't trust it to match existing accounts or to pass `allowed_domains` unless Entra marks the domain verified with the optional `xms_edov` claim. To have it sent, add the `email` and `xms_edov` optional claims to the ID token under **Token configuration**. Without it, existing users link Microsoft from their profile, and new users can still be created with `auto_create_users`.

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

Restart Knot to apply the configuration.


---

## Generic OIDC Setup

The generic OIDC provider supports any OpenID Connect compatible identity provider (Okta, Keycloak, Dex, and others). For Microsoft Entra ID, use the [Microsoft provider](#microsoft-setup). It uses OIDC discovery to automatically configure endpoints.

Multiple OIDC providers can be configured by adding separate `[[server.auth_providers]]` entries with different `name` values.

### 1. Configure your Identity Provider

Create an OAuth 2.0 / OpenID Connect client in your identity provider with:

- **Redirect URI** — `{your-knot-url}/auth/{name}/callback` where `{name}` is the `name` you configure below (e.g., `https://knot.example.com/auth/okta/callback`)
- **Scopes** — `openid`, `profile`, `email`, and `offline_access` with [`check_interval`](#checking-sign-ins-with-the-provider)
- **Response type** — `code` (Authorization Code flow)
- **Client authentication** — client secret sent in the request body (`client_secret_post`)
- **PKCE** — knot always sends an S256 code challenge, so this can be required
- **Back-channel logout URI** (optional) — `{your-knot-url}/auth/{name}/backchannel-logout`, so logging a user out or removing them at the provider ends their knot sessions straight away; see [Back-channel logout](#back-channel-logout)

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
scopes = ["openid", "profile", "email"]
```

The `name` field is a unique slug used in URLs (e.g., `/auth/okta/callback`): letters, digits, `-` and `_`, and not the name of a built-in provider such as `github`. The `display_name` is shown in the UI and is optional — it defaults to the capitalized `name`.

On startup, Knot fetches the discovery document to configure the authorization, token, and userinfo endpoints automatically. The document must include `issuer` and `jwks_uri`: knot verifies the ID token returned at sign-in against them.

### How knot verifies a sign-in

Each sign-in sends a `nonce` and a PKCE code challenge with the authorization request. When the provider redirects back, knot redeems the code with the PKCE verifier and checks the ID token it gets back:

- the signature, against the provider's published keys (`jwks_uri`); RSA (`RS256`/`384`/`512`, `PS256`/`384`/`512`), ECDSA (`ES256`/`384`/`512`) and `EdDSA` are accepted, and unsigned or HMAC-signed tokens are refused
- `iss` matches the discovery document's `issuer`
- `aud` contains the client ID, and `azp`, if present or if there are several audiences, is the client ID
- the token hasn't expired
- `nonce` matches the one knot sent

The user is identified by the ID token's `sub`. If the provider has a userinfo endpoint, knot reads the email and profile from it too, and refuses the sign-in if its `sub` differs from the ID token's. The PKCE verifier and nonce stay in an encrypted, HttpOnly cookie in the browser that started the sign-in; they never pass through the provider.

Restart Knot to apply the configuration.

### Back-channel logout

Without back-channel logout, a user logged out or removed at the identity provider stays signed in to knot until their knot session ends. Knot supports [OpenID Connect Back-Channel Logout 1.0](https://openid.net/specs/openid-connect-backchannel-1_0.html) for generic OIDC providers: register `{your-knot-url}/auth/{name}/backchannel-logout` as the client's back-channel logout URI (e.g., `https://knot.example.com/auth/okta/backchannel-logout`). Nothing needs setting in `knot.toml`.

When the provider logs the user out, it POSTs a signed logout token to that URI. Knot checks the token as it does an ID token (signature against `jwks_uri`, `iss`, `aud`), and also that:

- `iat` is less than five minutes old, and `exp` is present and hasn't passed
- `events` contains `http://schemas.openid.net/event/backchannel-logout`
- there is no `nonce`, so an ID token can't be passed off as a logout token
- `jti` hasn't been used before

It then ends every knot web session of the user linked to that provider identity (`sub`), on every server in the cluster, including sessions since switched to another user, and answers `200`. A token that fails a check gets `400`. A token for an identity no knot user is linked to gets `200` and changes nothing.

Knot matches the user by `sub`, so the logout token must include it; a token with only a `sid` is refused with `400`. Every session of the user ends, not just the one the provider's `sid` names.

[API tokens](../api-tokens.md) are not affected, including those `knot connect` and MCP clients got by signing in, so a computer connected to knot stays connected when the user signs out of the web interface. To end a user's access everywhere, deactivate them in knot, or have knot [check sign-ins with the provider](#checking-sign-ins-with-the-provider).

Each server remembers the `jti`s it has accepted for as long as their tokens would pass the `iat` check. The memory isn't shared between servers, so a captured token replayed to another server within those few minutes would end the same user's sessions again, and do nothing more.

### Roles and groups from the provider

A generic OIDC provider can assign knot roles and groups from the claims it sends. Turn it on with `sync_roles`:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "oidc"
name = "corp"
discovery_url = "https://id.example.com/.well-known/openid-configuration"
client_id = "knot"
client_secret = "your-oidc-client-secret"
sync_roles = true
claims = ["tags"]
claim_prefix = "knot:"
admin_name = "admin"
```

Then, in knot, give each role and group the provider should assign an **Identity Provider Name**. The field is on the [role](../access-control/roles.md#role-configuration-options) and [group](../access-control/groups.md#group-configuration-options) forms once a provider has `sync_roles` on. The built-in Admin role can't be edited, so its name comes from `admin_name` instead.

Each time a user signs in through the provider, knot:

1. Reads the claims listed in `claims` (default `roles` and `groups`) from the ID token and the userinfo response. A claim can be a string or an array of strings. A dotted name reaches into a nested object, such as Keycloak's `realm_access.roles`.
2. With `claim_prefix` set, keeps only the values that start with it and removes it, so `knot:developer` becomes `developer`. Values without the prefix are ignored, so the provider can carry claims for other applications too.
3. Matches the names, ignoring case, against the Identity Provider Names of every role and group. The user gets each role and group whose name is there, and loses each one that has an Identity Provider Name but isn't there.

Roles and groups without an Identity Provider Name are left to knot: assign them in the web UI as usual. Those with one belong to the provider: a change made to them in knot's user form is undone at the user's next sign-in.

Names from all the claims go into one list, checked against roles and groups alike. A role and a group with the same Identity Provider Name are both assigned by the same value, so give them different names.

For example, with the configuration above, a user whose `tags` claim is `["knot:developer", "knot:developer2", "billing"]` signs in to:

| Knot role or group | Identity Provider Name | Result |
| --- | --- | --- |
| Group *Developer* | `developer` | Assigned |
| Role *developer2* | `developer2` | Assigned |
| Built-in role *Admin* | `admin` (from `admin_name`) | Removed, if the user had it |
| Role *Support* | *(none)* | Unchanged |

`billing` has no `knot:` prefix, so knot ignores it.

A missing claim counts as no names, so it removes every role and group the provider assigns. Check the provider sends the claims, and that knot asks for any scope they need in `scopes`. Run knot with `--log-level debug` to log claims missing from a sign-in.

Changes take effect at the user's next sign-in through the provider, and their existing sessions keep the roles they had until then. With [`check_interval`](#checking-sign-ins-with-the-provider) set, each check also brings them up to date, so a change reaches signed-in users within the interval. Every change is recorded in the audit log, including Admin being granted or removed. [Back-channel logout](#back-channel-logout) ends the user's sessions, so they sign in again and pick up the change.

`sync_roles` works with `provider = "oidc"` only. On other providers knot logs a warning at startup and turns it off.

### MCP clients signing in through the provider

[MCP clients](../ai/mcp.md#oauth2-supported-clients) normally sign in with knot's own OAuth server. To have them sign in through a generic OIDC provider instead, set `oauth_server` to the provider's `name`:

```toml {filename=knot.toml}
[server]
oauth_server = "corp"
```

It can also be set with `--oauth-server` or `KNOT_OAUTH_SERVER`. The default, `builtin`, keeps knot's own server. Knot doesn't start if `oauth_server` names anything other than an `oidc` provider.

With `oauth_server` set, knot is only the MCP clients' resource server:

- The protected resource metadata at `/.well-known/oauth-protected-resource` names the provider's issuer as the authorization server, so MCP clients sign in there. It lists no scopes, since the provider doesn't know knot's.
- `/mcp` accepts the provider's access tokens for knot. A token must be a JWT of type `at+jwt` ([RFC 9068](https://www.rfc-editor.org/rfc/rfc9068)), signed with one of the provider's keys (`jwks_uri`), from its issuer, unexpired, and with `{server.url}/mcp` in `aud`. The provider must support resource indicators ([RFC 8707](https://www.rfc-editor.org/rfc/rfc8707)) to issue it for that audience.
- The token's `sub` must be linked to an active knot user, so each user signs in to knot through the provider once before their MCP clients can connect. They then act as that user, with that user's permissions, including **Use MCP Server**.
- The provider's tokens reach `/mcp` only. The rest of the API refuses them.
- Knot's own authorization endpoints are turned off: `/authorize`, `/register` and `/.well-known/oauth-authorization-server` answer `404`, and `/token` accepts only the device code grant that [`knot connect`](../../knot-reference/cli/knot.md#knot-connect) uses.
- Tokens knot's own OAuth server issued to MCP clients earlier no longer work at `/mcp`, so those clients sign in again through the provider. API tokens a user created, and those from `knot connect`, still work.

MCP access then follows the provider: once it stops issuing a user tokens for knot, their MCP clients lose access when their current token expires.

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
| `provider` | string | Yes | The provider type: `github`, `gitlab`, `google`, `microsoft`, `auth0`, or `oidc` |
| `name` | string | Yes for `oidc` | Unique slug for OIDC providers (used in URLs and display) |
| `display_name` | string | No | Display name in the UI (OIDC and Microsoft only; defaults to capitalized `name`, or Microsoft) |
| `client_id` | string | Yes | OAuth client ID from the provider |
| `client_secret` | string | Yes | OAuth client secret from the provider |
| `base_url` | string | No | Custom base URL (required for Auth0 tenant domain; defaults to `https://gitlab.com` for GitLab) |
| `discovery_url` | string | Yes for `oidc` | OIDC discovery document URL (e.g., `/.well-known/openid-configuration`) |
| `scopes` | string[] | No | Replace the scopes requested during login (the list is used as given, not merged with the defaults). Defaults: GitHub `user:email`; GitLab `read_user`; Google `openid email profile`; Microsoft `openid profile email`; Auth0 `openid profile email`; OIDC `openid profile email` |
| `tenant` | string | No | Microsoft only: the directory (tenant) ID, a tenant domain, or `organizations` (the default) |
| `allowed_tenants` | string[] | Microsoft only, unless `tenant` is a tenant ID | Tenant IDs whose users can sign in |
| `allowed_domains` | string[] | No | Restrict login to users with verified email addresses in these domains |
| `auto_create_users` | bool | No | Automatically create a Knot user account on first login |
| `link_by_email` | bool | No | Whether a first sign-in through this provider may join an existing Knot account with the same verified email (default `true`). Set `false` for a provider whose `email_verified` you don't trust, such as a self-managed GitLab or an Auth0 tenant with open sign-up; users then link it from their profile |
| `insecure_skip_tls` | bool | No | Accept any TLS certificate from this provider, for a self-hosted one with a self-signed certificate. Anyone on the network path between knot and the provider could then impersonate it, including its signing keys, so use it only for test and lab setups |
| `default_roles` | string[] | No | Role names assigned to auto-created users |
| `default_groups` | string[] | No | Group names assigned to auto-created users |
| `require_sso` | bool | No | Users linked to this provider must sign in through it; their password no longer signs them in. See [Requiring single sign-on](#requiring-single-sign-on) |
| `sync_roles` | bool | No | OIDC only: assign the roles and groups that have an Identity Provider Name from the provider's claims on every sign-in. See [Roles and groups from the provider](#roles-and-groups-from-the-provider) |
| `claims` | string[] | No | With `sync_roles`: the claims holding role and group names (default `["roles", "groups"]`). A dotted name reaches into a nested object |
| `claim_prefix` | string | No | With `sync_roles`: only claim values starting with this are used, with it removed (e.g. `knot:`) |
| `admin_name` | string | No | With `sync_roles`: the name that assigns the built-in Admin role. Empty leaves Admin to knot |
| `check_interval` | duration | No | How often knot checks with the provider that a web session's sign-in still stands, such as `1h`; at least `5m`. Unset, sign-ins aren't checked. See [Checking sign-ins with the provider](#checking-sign-ins-with-the-provider) |

The `[server]` setting `oauth_server` (default `builtin`) can name a generic OIDC provider for MCP clients to sign in through. See [MCP clients signing in through the provider](#mcp-clients-signing-in-through-the-provider).

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
scopes = ["openid", "profile", "email"]
auto_create_users = true
default_roles = ["User"]
default_groups = ["Developers"]
```

---

## User Experience

When OAuth providers are configured:

- **Sign-in buttons** for each enabled provider appear on the Knot login page alongside the standard email/password form.
- On first login via OAuth, Knot either matches the user by email address or creates a new account (if `auto_create_users` is enabled). It matches by email only when the provider says the email is verified, the provider's `link_by_email` isn't off, and the account isn't already linked to a different identity at the same provider. Otherwise the user signs in with their password and links the provider from their profile.
- Signing in through a provider trusts the provider's own sign-in, including its multi-factor authentication, and skips Knot's password and TOTP. So Knot never matches by email an account that has TOTP set up or is an administrator: the owner signs in with their password and TOTP and links the provider from their profile, after which the provider signs them in.
- Users can **link** and **unlink** OAuth providers from their profile settings.
- Users created via OAuth are prompted to set a password, unless the provider has [`require_sso`](#requiring-single-sign-on) on.
- Knot keeps only the provider identity it signs a user in as, never the provider's access or refresh tokens, and doesn't ask for offline access. A sign-in on one server of a zone signs the user in on all of them, through Knot's own session.

### Domain Restrictions

When `allowed_domains` is set, only users with a verified email address in one of the listed domains can authenticate. For GitHub, this checks the user's public or primary verified email. For GitLab, it checks the account's email, once confirmed. For Google and Auth0, it checks the email returned by the userinfo endpoint, which must have `email_verified` set. For OIDC providers, it checks the email from the userinfo endpoint, or from the ID token when the provider has no userinfo endpoint, which must have `email_verified` set. For Microsoft, it needs the `xms_edov` claim; use `allowed_tenants` to restrict Microsoft sign-in instead.

### Requiring single sign-on

A user linked to a provider can normally still sign in with their knot password, so turning them away at the provider doesn't keep them out of knot. Set `require_sso` on the provider to close that gap:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "oidc"
name = "corp"
# ...
require_sso = true
```

For every user linked to the provider:

- Signing in with a password is refused, and the refusal is recorded in the audit log. Knot checks the password first, so the refusal only reveals the account to someone who knows it.
- Knot doesn't ask them to set a password after their first sign-in.
- They can't unlink the provider from their profile. An administrator with **Manage Users** still can.

[`knot connect`](../../knot-reference/cli/knot.md#knot-connect) signs in through the browser, so it works for these users too.

Unlike `disable_password_auth`, which turns password sign-in off for everyone, `require_sso` only affects users linked to that provider. Other accounts, such as a local administrator kept for emergencies, still sign in with a password.

API tokens a user already has keep working, so deactivate the user in knot to end their access everywhere. With [`check_interval`](#checking-sign-ins-with-the-provider) set, knot does this itself once the provider refuses the user.

---

## Checking sign-ins with the provider

A knot session doesn't depend on the provider once it's signed in: a user suspended or removed at the provider stays signed in to knot until their session ends, and keeps their API tokens. Set `check_interval` on a provider to have knot check:

```toml {filename=knot.toml}
[[server.auth_providers]]
provider = "google"
client_id = "your-google-client-id.apps.googleusercontent.com"
client_secret = "your-google-client-secret"
check_interval = "1h"
```

At sign-in, knot keeps the provider's grant with the web session, encrypted with `server.encrypt`. Once per `check_interval`, for every live session the provider signed in, knot uses the grant to ask the provider whether the sign-in still stands:

| Provider | What knot keeps | What the check does |
| --- | --- | --- |
| Google | Refresh token | Refreshes it |
| GitLab | Refresh token | Refreshes it |
| Microsoft | Refresh token | Refreshes it |
| Auth0 | Refresh token | Refreshes it |
| Generic OIDC | Refresh token | Refreshes it, and reads the user's claims again |
| GitHub | Access token, or the refresh token of a GitHub App with expiring tokens | Reads the user's GitHub profile |

To get a grant that lasts while the user is away, knot asks Microsoft, Auth0 and generic OIDC providers for the `offline_access` scope, adding it to `scopes` if it isn't there, and asks Google for offline access. Google only gives a refresh token with consent, so with `check_interval` set it shows its consent screen at every sign-in. Allow refresh tokens, or offline access, for knot's client at the provider.

What happens next depends on the answer:

- **The sign-in stands.** Knot keeps the grant, replacing it if the provider sent a new one. For a generic OIDC provider with [`sync_roles`](#roles-and-groups-from-the-provider), it also updates the roles and groups the provider manages from the fresh claims.
- **The provider refuses the grant**, with `invalid_grant` from its token endpoint or, for GitHub, `401`. The user, or their access to knot, is gone:
  - A user with another way in, such as another linked provider or a password that can still sign them in, loses the web sessions the provider signed in. Their other sessions and their API tokens are kept.
  - A user the provider was the only way in for is deactivated, which ends their sessions and stops their API tokens, including those of `knot connect` and MCP clients. An administrator reactivates them.
  - The last active administrator is never deactivated: their sessions end and the audit log says why, so a provider can't lock everyone out.
- **No answer**, such as a timeout, a `5xx` or a provider that's down. Nothing changes, and knot tries again five minutes later.

Every refusal is recorded in the audit log with the provider's error.

A refusal doesn't always mean the user lost access. Knot also treats these as refusals:

- The user taking knot's access away in their own account at the provider, such as in their Google account's settings.
- Google apps in testing mode, whose refresh tokens expire after seven days. Publish the app.
- Providers that end refresh tokens when the user changes or resets their password, or when an administrator signs all their sessions out.

Knot keeps only a refresh token that the provider says was granted `offline_access`, when it says, so a user signing out at a generic OIDC provider isn't taken for a refusal.

In a [cluster](cluster-mode.md), the leader of each zone checks its zone's sessions. A session, and its grant, belong to one zone, so no two servers use the same grant.

Only web sessions are checked. A user who only uses `knot connect` or MCP isn't checked until they next sign in to the web interface. Sessions signed in before `check_interval` was set have no grant, so they aren't checked either.

---

## Callback URLs

The OAuth callback URLs follow a consistent pattern based on your configured `server.url`:

| Provider | Callback URL |
| --- | --- |
| GitHub | `{server.url}/auth/github/callback` |
| GitLab | `{server.url}/auth/gitlab/callback` |
| Google | `{server.url}/auth/google/callback` |
| Microsoft | `{server.url}/auth/microsoft/callback` |
| Auth0 | `{server.url}/auth/auth0/callback` |
| Generic OIDC | `{server.url}/auth/{name}/callback` |

Ensure these URLs are registered as authorized redirect URIs in your provider's application settings.

Generic OIDC providers can also register `{server.url}/auth/{name}/backchannel-logout` as the back-channel logout URI ([details](#back-channel-logout)).
