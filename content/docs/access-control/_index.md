---
title: Access Control
weight: 30
---

Access control in **knot** uses a combination of users, roles, and groups to manage permissions and resource access.

---

## Overview

**Users** are individual accounts with credentials.

**Roles** define what actions users can perform (permissions).

**Groups** control which templates users can access and set resource quotas.

This three-tier system provides flexible, fine-grained access control.

---

## Users

Users are created and managed through the web interface. Each user has:

- Username and password
- Email address
- SSH public key (optional)
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

**Developer Role**
- Create and manage own spaces
- Access SSH and terminal
- Use port forwarding
- View own audit logs

**QA Tester Role**
- Create test spaces
- View space logs
- Access terminal
- Limited to test templates

**Template Admin Role**
- Create and edit templates
- Manage template groups
- View all spaces using templates

**User Admin Role**
- Create and manage users
- Assign roles and groups
- Set user quotas
- View user activity

**System Admin Role**
- Full system access
- Manage all resources
- Configure server settings
- Access all audit logs

### Permission Matrix

| Permission | Developer | QA | Template Admin | User Admin | System Admin |
|------------|-----------|-----|----------------|------------|-------------|
| Create own spaces | ✓ | ✓ | ✓ | ✓ | ✓ |
| Delete own spaces | ✓ | ✓ | ✓ | ✓ | ✓ |
| SSH access | ✓ | ✓ | ✓ | ✓ | ✓ |
| Create templates | | | ✓ | | ✓ |
| Edit templates | | | ✓ | | ✓ |
| Create users | | | | ✓ | ✓ |
| Manage roles | | | | ✓ | ✓ |
| View all spaces | | | | | ✓ |
| Server config | | | | | ✓ |

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
- Quotas are additive
- Highest privilege applies

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
- Set short token expiration

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

System administrators can:
- Create spaces for other users
- View and manage all spaces
- Access all templates
- Modify any resource
- View complete audit logs
- Manage system configuration

Use admin access carefully and audit admin actions.

---

## What's Next

- [Users](users/)
- [Roles](roles/)
- [Groups](groups/)
