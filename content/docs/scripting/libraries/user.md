---
title: knot.user
weight: 70
---

The `knot.user` library provides user management functions.

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all users |
| `get(user_id)` | Get user by ID, username, or email |
| `create(username, email, password, ...)` | Create a new user |
| `update(user_id, ...)` | Update user properties |
| `delete(user_id)` | Delete a user |
| `get_current()` | Get the current user |

---

## Usage

```python
import knot.user as user

# Get current user
me = user.get_current()
print(me['username'])

# List users
users = user.list()
for u in users:
    print(f"{u['username']}: {u['email']}")
```
