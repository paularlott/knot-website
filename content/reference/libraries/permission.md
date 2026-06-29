---
title: knot.permission
weight: 110
---

The `knot.permission` library provides permission constants and a function to list available permissions.

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all available permissions with IDs, names, and groups |

---

## Permission Constants

The library provides constants for all permissions:

### User Management
| Constant | ID | Description |
|----------|-----|-------------|
| `MANAGE_USERS` | 0 | Manage users |
| `MANAGE_GROUPS` | 4 | Manage groups |
| `MANAGE_ROLES` | 5 | Manage roles |

### Resource Management
| Constant | ID | Description |
|----------|-----|-------------|
| `MANAGE_SPACES` | 2 | Manage spaces |
| `MANAGE_TEMPLATES` | 1 | Manage templates |
| `MANAGE_VOLUMES` | 3 | Manage volumes |
| `MANAGE_VARIABLES` | 6 | Manage variables |

### Space Operations
| Constant | ID | Description |
|----------|-----|-------------|
| `USE_SPACES` | 7 | Use spaces |
| `TRANSFER_SPACES` | 10 | Transfer spaces |
| `SHARE_SPACES` | 11 | Share spaces |
| `USE_TUNNELS` | 8 | Use tunnels |

### System & Audit
| Constant | ID | Description |
|----------|-----|-------------|
| `VIEW_AUDIT_LOGS` | 9 | View audit logs |
| `CLUSTER_INFO` | 12 | View cluster info |

### Space Features
| Constant | ID | Description |
|----------|-----|-------------|
| `USE_VNC` | 13 | Use VNC |
| `USE_WEB_TERMINAL` | 14 | Use web terminal |
| `USE_SSH` | 15 | Use SSH |
| `USE_CODE_SERVER` | 16 | Use code-server |
| `USE_VSCODE_TUNNEL` | 17 | Use VS Code tunnel |
| `USE_LOGS` | 18 | View logs |
| `RUN_COMMANDS` | 19 | Run commands |
| `COPY_FILES` | 20 | Copy files |

### AI Tools
| Constant | ID | Description |
|----------|-----|-------------|
| `USE_MCP_SERVER` | 21 | Use MCP server |
| `USE_WEB_ASSISTANT` | 22 | Use web assistant |

### Scripting
| Constant | ID | Description |
|----------|-----|-------------|
| `MANAGE_SCRIPTS` | 23 | Manage all scripts |
| `EXECUTE_SCRIPTS` | 24 | Execute scripts |
| `MANAGE_OWN_SCRIPTS` | 25 | Manage own scripts |
| `EXECUTE_OWN_SCRIPTS` | 26 | Execute own scripts |

### Skills
| Constant | ID | Description |
|----------|-----|-------------|
| `MANAGE_GLOBAL_SKILLS` | 27 | Manage global skills |
| `MANAGE_OWN_SKILLS` | 28 | Manage own skills |

### Aliases
| Alias | Equivalent |
|-------|------------|
| `SPACE_MANAGE` | `MANAGE_SPACES` |
| `SPACE_USE` | `USE_SPACES` |
| `SCRIPT_MANAGE` | `MANAGE_SCRIPTS` |
| `SCRIPT_EXECUTE` | `EXECUTE_SCRIPTS` |

---

## Usage

```python
import knot.permission as perm
import knot.user as user

# List all permissions
permissions = perm.list()
for p in permissions:
    print(f"{p['id']}: {p['name']} ({p['group']})")

# Check if user has a specific permission using user library
me = user.get_me()
if user.has_permission(me['id'], perm.MANAGE_SPACES):
    print("User can manage spaces")

# Using constants
if user.has_permission(me['id'], perm.USE_SPACES):
    print("User can use spaces")
```

---

## Checking Permissions

To check if a user has a specific permission, use `knot.user.has_permission(user_id, permission_id)` with the permission constants:

```python
import knot.permission as perm
import knot.user as user

me = user.get_me()

# Check individual permissions
if user.has_permission(me['id'], perm.MANAGE_SPACES):
    print("Can manage all spaces")

if user.has_permission(me['id'], perm.USE_VNC):
    print("Can use VNC")
```
