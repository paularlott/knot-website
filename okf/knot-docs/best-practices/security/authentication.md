---
description: User authentication and access control.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/best-practices/security/authentication/
sources:
    - resource: https://getknot.dev/docs/best-practices/security/authentication/
status: stable
tags:
    - security
    - authentication
title: Authentication
type: Guide
---
# Authentication

User authentication and access control.

---

## Password Requirements

Enforce strong passwords:
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- No common passwords or dictionary words
- Regular password rotation

---

## Two-Factor Authentication

Enable TOTP-based 2FA:

```toml {filename=knot.toml}
[server.totp]
enabled = true
issuer = "Knot"
```

Users configure 2FA in their profile using authenticator apps.

**When to require 2FA**:
- All admin accounts (always)
- Any internet-exposed deployment (required)
- High-security environments (recommended)
- Contractor or temporary access (recommended)

---

## API Token Security

- Tokens expire after 2 weeks of inactivity
- Revoke tokens immediately when no longer needed
- Use separate tokens for different applications
- Never commit tokens to version control
- Rotate tokens regularly

---

## Rate Limiting

Failed-login rate limiting is always on and protects against brute force attacks. After too many failed logins for an IP address or email within the window, further attempts from that source are blocked for the block duration:

```toml {filename=knot.toml}
[server]
auth_rate_limit_attempts = 10  # failed attempts before blocking (default 10)
auth_rate_limit_window = 60    # seconds failures are counted over (default 60)
auth_rate_limit_block = 300    # seconds auth stays blocked (default 300)
```

Failed authentication attempts are logged for monitoring.

---

## Disabling Password Authentication

In Knot Pro  username and password authentication can be disabled entirely, requiring OAuth providers instead:

```toml {filename=knot.toml}
[server]
disable_password_auth = true
```

With password auth disabled, a user unlinking one of their own OAuth providers must have at least two providers linked — otherwise they would lock themselves out.

---

## Access Control

Roles, groups, quotas, and the full permission reference are covered in [Access Control](../../access-control.md).
