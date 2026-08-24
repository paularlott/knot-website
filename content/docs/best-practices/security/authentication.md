---
title: Authentication
description: User authentication and access control.
type: Guide
tags: [security, authentication]
weight: 20
---

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

In Knot Pro {{< pro-badge >}} username and password authentication can be disabled entirely, requiring OAuth providers instead:

```toml {filename=knot.toml}
[server]
disable_password_auth = true
```

With password auth disabled, a user unlinking one of their own OAuth providers must have at least two providers linked — otherwise they would lock themselves out.

---

## Access Control

### Principle of Least Privilege

Grant users minimum necessary permissions:
- Create specific roles for different functions
- Assign users to appropriate groups
- Limit admin access to essential personnel
- Regular access reviews

### Role-Based Access Control

Define roles with specific permissions:
- `developer`: Create and manage own spaces
- `viewer`: Read-only access
- `template-admin`: Manage templates
- `user-admin`: Manage users and groups
- `system-admin`: Full system access

### Resource Quotas

Prevent resource abuse:
- Limit number of spaces per user
- Set compute unit limits
- Restrict storage allocation
- Monitor quota usage
