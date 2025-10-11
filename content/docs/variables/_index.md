---
title: Variables
weight: 40
---

Variables make templates flexible and reusable. They allow you to inject dynamic values into container specifications and volume definitions at runtime.

---

## Variable Types

**System Variables**
Automatically provided by knot. Include user information, space details, and server configuration.

**User-Defined Variables**
Created by administrators in the web interface. Shared across templates for common configuration values.

**Custom Variables**
Defined in templates. Users provide values when creating spaces for per-space customization.

---

## Variable Syntax

Variables use Go template syntax:

```
${{ .group.name }}
```

Examples:
- `${{ .user.username }}` - Current user's username
- `${{ .space.name }}` - Space name
- `${{ .var.registry_url }}` - User-defined variable
- `${{ .custom.branch }}` - Custom variable

---

## Common Use Cases

### Dynamic Container Names

```yaml
container_name: ${{ .user.username }}-${{ .space.name }}
hostname: ${{ .space.name }}
```

Creates unique container names like `john-myproject`.

### User Home Directories

```yaml
volumes:
  - home:/home/${{ .user.username }}
```

Mounts volumes to user-specific paths.

### Environment Configuration

```yaml
environment:
  - "TZ=${{ .user.timezone }}"
  - "USER=${{ .user.username }}"
  - "KNOT_SERVER=${{ .server.url }}"
```

Configures containers with user and server details.

### Registry Authentication

```hcl
auth {
  username = "${{ .var.registry_user }}"
  password = "${{ .var.registry_pass }}"
}
```

Uses user-defined variables for credentials.

### Per-Space Configuration

```yaml
environment:
  - "GIT_BRANCH=${{ .custom.branch }}"
  - "API_KEY=${{ .custom.api_key }}"
```

Allows users to customize each space.



---

## What's Next

- [System Variables](system-variables/)
- [User-Defined Variables](user-defined-variables/)
- [Custom Variables](custom-variables/)
