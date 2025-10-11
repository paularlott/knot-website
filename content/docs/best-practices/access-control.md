---
title: Access Control
weight: 30
---

Best practices for managing users, roles, and groups.

---

## Principle of Least Privilege

Grant minimum necessary permissions:
- Start restrictive, expand as needed
- Don't give everyone admin access
- Create specific roles for specific functions
- Regular review and removal of unnecessary permissions

---

## Use Groups for Template Access

Don't make all templates available to everyone:
- Organize by team: `backend-team`, `frontend-team`
- Organize by project: `project-alpha`, `project-beta`
- Organize by purpose: `development`, `testing`, `demos`

This keeps template lists manageable and relevant.

---

## Separate Roles by Function

Create specific roles rather than one "power user" role:
- `developer`: Create and manage own spaces
- `template-admin`: Manage templates
- `user-admin`: Manage users
- `auditor`: View logs and reports

Avoid combining unrelated permissions.

---

## Regular Access Reviews

Periodically review user access:
- Monthly review of active users
- Quarterly review of permissions
- Remove inactive accounts
- Update permissions as roles change
- Document access decisions

---

## Document Role Definitions

Clearly document what each role can do:

```
Developer Role:
- Create spaces from assigned templates
- Manage own spaces (start, stop, delete)
- Access SSH and terminal
- Use port forwarding
- View own audit logs

Cannot:
- Create or modify templates
- Manage other users
- View other users' spaces
```

---

## Set Appropriate Quotas

Balance flexibility with resource constraints:
- Developers: 3-5 spaces, 10-20 compute units
- QA: 2-3 spaces, 5-10 compute units
- Contractors: 1-2 spaces, 3-5 compute units

Monitor usage and adjust based on actual needs.

---

## Use Descriptive Names

Name roles and groups clearly:
- Good: `backend-developers`, `qa-testers`, `project-alpha-team`
- Bad: `group1`, `role-a`, `team`

Descriptive names make management easier.

---

## Separate Production and Development

Use groups to separate environments:
- `prod-access`: Production templates
- `dev-access`: Development templates
- `staging-access`: Staging templates

Limit production access to necessary personnel.
