---
title: Access Control
weight: 30
---

Access within **knot** is managed through a combination of user accounts, roles, and groups. These elements work together to control access to resources, features, and templates, ensuring a secure and organized environment.

---

### Users

Users are created and managed through the **knot** web interface. They can be assigned to groups and roles to define their access to resources and features within **knot**.

- **Resource Quotas**: Each user can be assigned a resource quota to limit the number of spaces they can create or run simultaneously.

---

### Groups

Groups are used to control access to templates and manage resource quotas.

- **Template Access**: Users can only view templates and create spaces from templates that belong to groups they are a member of.

- **Resource Quotas**: Groups can define quotas, such as limiting all users in the `Developer` group to creating up to 4 spaces.

- **Multiple Groups**: When a user belongs to multiple groups, they gain access to resources from all groups. Quotas from each group are combined.

---

### Roles

Roles define permissions and control access to features within **knot**.

- **Permissions**: Each role includes one or more permissions that determine what features a user can access.

- **Multiple Roles**: When a user is assigned multiple roles, the permissions from all roles are combined, granting the user access to all associated features.
