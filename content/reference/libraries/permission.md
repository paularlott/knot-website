---
title: knot.permission
description: Permission constants and a function to list available permissions.
type: API Reference
tags: [security, authentication, api, scripting]
weight: 120
---

The `knot.permission` library provides permission constants and a function to list available permissions.

---

## Execution Environment

| Environment | Behaviour |
|-------------|-----------|
| Embedded (MCP tool execution, event sinks, plugin handlers, remote/space scripts, `knot run-script`) | Available; authenticated automatically via the Go-provided `knot.apiclient` transport. |
| Health check scripts | Not available. |
| External (standalone scripts) | Python implementation; configure `knot.apiclient` first (or set the `KNOT_*` environment variables). |

---

## Functions

| Function | Description |
|----------|-------------|
| `list()` | List all available permissions with IDs, names, and groups |
| `list_plugin()` | List the permissions declared by loaded plugins — the qualified grant ids (`plugin.<name>.<id>`) roles may carry |

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
| `EDIT_SPACE_JOBS` | 43 | Edit the scheduled jobs of your own spaces |

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

### Space Forms & Templates
| Constant | ID | Description |
|----------|-----|-------------|
| `SET_SPACE_DEPENDENCIES` | 29 | Configure dependencies between spaces |
| `USE_SPACE_STARTUP_SCRIPT` | 30 | Set a user startup script that runs when a space starts |

### Audit
| Constant | ID | Description |
|----------|-----|-------------|
| `DOWNLOAD_AUDIT_LOGS` | 31 | Download (export) audit logs |

### Stack Definitions
| Constant | ID | Description |
|----------|-----|-------------|
| `MANAGE_STACK_DEFINITIONS` | 32 | Manage global (system) stack definitions |
| `MANAGE_OWN_STACK_DEFINITIONS` | 33 | Manage own stack definitions |
| `USE_STACK_DEFINITIONS` | 34 | Create spaces from stack definitions |

### Methods & Pools
| Constant | ID | Description |
|----------|-----|-------------|
| `USE_METHODS` | 35 | Call space methods shared by other users |
| `USE_POOLS` | 36 | Create and run space pools |

### Events
| Constant | ID | Description |
|----------|-----|-------------|
| `MANAGE_EVENTS` | 37 | Manage own event sinks |
| `MANAGE_GLOBAL_EVENTS` | 38 | Manage global event sinks |

### Slash Commands
| Constant | ID | Description |
|----------|-----|-------------|
| `MANAGE_GLOBAL_SLASH_COMMANDS` | 39 | Manage global slash commands |
| `MANAGE_OWN_SLASH_COMMANDS` | 40 | Manage own slash commands |

### MCP Servers
| Constant | ID | Description |
|----------|-----|-------------|
| `MANAGE_MCP_SERVERS` | 41 | Register and configure MCP servers |

### Log Sinks {{< pro-badge >}}
| Constant | ID | Description |
|----------|-----|-------------|
| `USE_LOG_SINKS` | 42 | Register a space as a log sink receiving the owner's other space logs (enforced by Knot Pro only) |

### Plugins
| Constant | ID | Description |
|----------|-----|-------------|
| `VIEW_PLUGINS` | 44 | View the loaded plugins inventory |

### User Linking
| Constant | ID | Description |
|----------|-----|-------------|
| `LINK_USERS` | 45 | Link user accounts for fast user switching (impersonation-grade) |

### File Storage
| Constant | ID | Description |
|----------|-----|-------------|
| `USE_FILES` | 46 | Use file storage: own buckets and buckets shared with you |
| `MANAGE_FILES` | 47 | Full access to every bucket, including sharing and transferring any bucket |
| `SHARE_BUCKETS` | 48 | Share own buckets with users, groups or everyone |
| `TRANSFER_BUCKETS` | 49 | Transfer own buckets to another user |

### System
| Constant | ID | Description |
|----------|-----|-------------|
| `BACKUP_SERVER` | 50 | Back up and restore all server data; equivalent to full access and not part of the Admin role |
| `USE_USER_SECRETS` | 51 | Store a 1Password service account token and read your own secrets from your spaces (enforced by Knot Pro only) |

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
