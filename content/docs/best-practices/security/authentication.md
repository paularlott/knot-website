---
title: Authentication
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

IP-based rate limiting protects against brute force attacks:

```toml {filename=knot.toml}
[server.rate_limit]
enabled = true
max_attempts = 5
window = "15m"
```

Failed authentication attempts are logged for monitoring.

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
