---
title: knot.user
weight: 70
---

The `knot.user` library provides user management functions.

---

## Functions

| Function | Description |
|----------|-------------|
| `list(state='', zone='')` | List all users with optional filters |
| `get(user_id)` | Get user by ID, username, or email |
| `get_me()` | Get the current user |
| `create(username, email, password, ...)` | Create a new user |
| `update(user_id, ...)` | Update user properties |
| `delete(user_id)` | Delete a user |
| `get_quota(user_id)` | Get user quota and usage |
| `list_permissions(user_id)` | List all permissions for a user |
| `has_permission(user_id, permission_id)` | Check if user has a specific permission |

---

## Usage

```python
import knot.user as user

# Get current user
me = user.get_me()
print(me['username'])

# List users
users = user.list()
for u in users:
    print(f"{u['username']}: {u['email']}")

# Get a specific user
u = user.get("some-user-id")
print(u['username'])

# Check permissions
if user.has_permission(me['id'], 2):  # MANAGE_SPACES = 2
    print("User can manage spaces")

# Get quota information
quota = user.get_quota(me['id'])
print(f"Spaces: {quota['number_spaces']}/{quota['max_spaces']}")
```

---

## User Properties

Users contain:
- `id` - User ID
- `username` - Username
- `email` - Email address
- `active` - Whether user is active
- `max_spaces` - Maximum spaces allowed
- `compute_units` - Compute units quota
- `storage_units` - Storage units quota
- `max_tunnels` - Maximum tunnels allowed
- `preferred_shell` - Preferred shell
- `timezone` - User timezone
- `github_username` - GitHub username
- `number_spaces` - Current number of spaces
- `number_spaces_deployed` - Number of running spaces
- `used_compute_units` - Used compute units
- `used_storage_units` - Used storage units
- `used_tunnels` - Used tunnels
- `current` - Whether this is the current user
- `roles` - List of role names
- `groups` - List of group names

---

## Quota Properties

`get_quota()` returns:
- `max_spaces` - Maximum spaces allowed
- `compute_units` - Compute units quota
- `storage_units` - Storage units quota
- `max_tunnels` - Maximum tunnels allowed
- `number_spaces` - Current number of spaces
- `number_spaces_deployed` - Number of running spaces
- `used_compute_units` - Used compute units
- `used_storage_units` - Used storage units
- `used_tunnels` - Used tunnels
