---
description: Manage permissions and resource access in knot using users, roles, and groups.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/access-control/
sources:
    - resource: https://getknot.dev/docs/access-control/
status: stable
tags:
    - security
    - authentication
title: Access Control
type: Overview
---
# Access Control

Access control in Knot uses a combination of users, roles, and groups to manage permissions and resource access.

---

## Overview

**Users** are individual accounts with credentials.

**Roles** define what actions users can perform (permissions).

**Groups** control which templates users can access and set resource quotas.

This three-tier system provides flexible, fine-grained access control.

---

## Users

Users are created and managed through the web interface. Each user has:

- Username (at most 30 characters, ending in a letter or digit; it can't be changed later) and password
- Email address
- SSH public key (optional)
- SSH private key in their own profile (optional)
- Timezone preference
- Role assignments
- Group memberships
- Resource quotas

### User Quotas

Users can be limited by:
- **Max Spaces**: Total number of spaces (running + stopped)
- **Compute Units**: Resources for running spaces
- **Storage Units**: Total storage allocation

Quotas prevent resource abuse and ensure fair distribution.

---

## Roles

Roles grant permissions for specific actions. Users can have multiple roles, and permissions are combined.

### Common Role Examples

The roles below are examples of how permissions can be combined — Knot only ships the built-in **Admin** and **Backup User** roles. Permission names match the [role form](access-control/roles.md#available-permissions).

**Developer Role**
- Use Spaces
- Use Web Terminal, Use SSH, Use Code Server, Use VSCode Tunnel
- View Logs, Copy Files
- Use Tunnels

**QA Tester Role**
- Use Spaces
- Use Web Terminal, View Logs
- Combine with a group that only holds the test templates

**Template Admin Role**
- Manage Templates
- Manage Volumes
- Manage Variables

**User Admin Role**
- Manage Users
- Manage Groups
- Manage Roles

**Admin Role** (built in)
- Every permission except Backup Server

### Example Permission Matrix

| Permission | Developer | QA | Template Admin | User Admin | Admin |
|------------|-----------|-----|----------------|------------|-------------|
| Use Spaces | ✓ | ✓ | | | ✓ |
| Use Web Terminal | ✓ | ✓ | | | ✓ |
| Use SSH | ✓ | | | | ✓ |
| Use Tunnels | ✓ | | | | ✓ |
| Manage Templates | | | ✓ | | ✓ |
| Manage Volumes | | | ✓ | | ✓ |
| Manage Users | | | | ✓ | ✓ |
| Manage Roles | | | | ✓ | ✓ |
| Manage Spaces (any user's) | | | | | ✓ |
| Backup Server | | | | | |

**Backup Server** is root-equivalent and is held only by the **Backup User** role (or any role you add it to). See [Backup and Restore](best-practices/backup-restore.md).

---

## Groups

Groups control template access and provide additional quotas.

### Template Access

Users only see templates assigned to their groups. This allows:
- Team-specific templates
- Project-specific environments
- Role-appropriate tools

Example:
- `backend-team` group sees Node.js and Python templates
- `frontend-team` group sees React and Vue templates
- `data-team` group sees Jupyter and R templates

### Group Quotas

Groups can define quotas that apply to all members:
- `developers` group: 5 spaces, 15 compute units
- `contractors` group: 2 spaces, 5 compute units
- `admins` group: unlimited

### Multiple Group Membership

When a user belongs to multiple groups:
- They see templates from all groups
- Quotas are additive, and add to the user's own limits

Groups don't grant permissions — those come only from roles.

Example:
- User in `developers` (5 spaces) and `qa-team` (3 spaces)
- Total quota: 8 spaces
- Access to templates from both groups

---

## Access Control Scenarios

### Scenario 1: Development Team

**Setup**:
- Create `developers` group
- Assign development templates to group
- Create `developer` role with space management permissions
- Add team members to group and role

**Result**: Developers can create spaces from dev templates within their quotas.

### Scenario 2: Contractors

**Setup**:
- Create `contractors` group with limited quotas
- Assign only necessary templates
- Create `contractor` role with restricted permissions
- Issue scoped API tokens where possible — e.g. a [tunnels-only](api-tokens.md#scoping-a-token) key for machines that just expose a port
- Delete their API tokens when the engagement ends — token lifetime isn't configurable; unused tokens expire after two weeks

**Result**: Contractors have limited, controlled access.

### Scenario 3: Multi-Team Organization

**Setup**:
- Create groups per team: `backend`, `frontend`, `devops`
- Create role per function: `developer`, `lead`, `admin`
- Assign templates to appropriate groups
- Assign users to relevant groups and roles

**Result**: Each team sees their templates, roles define what they can do.

---

## Admin Capabilities

Users with the built-in Admin role can:
- Create spaces for other users
- View and manage all spaces
- Access all templates
- Modify any resource
- View complete audit logs

Admin doesn't include **Backup Server**: backing up and restoring the server needs the **Backup User** role (or another role with that permission). Server settings live in `knot.toml`, not in roles.

Use admin access carefully and audit admin actions.

---

## What's Next

- [Users](access-control/users.md)
- [Roles](access-control/roles.md)
- [Groups](access-control/groups.md)
