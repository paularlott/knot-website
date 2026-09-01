---
title: Managing Roles
description: Create, edit, and delete roles and assign permissions that define what users can do in knot.
type: Guide
tags: [security, authentication]
weight: 20
---

In Knot, roles are used to control access to features. Each role is assigned one or more permissions, which define what a user can do within the system. When a user is assigned multiple roles, the permissions from all roles are combined, granting the user access to all associated features.

---

### Creating Roles

To create a new role:

1. From the `Administration` menu, select `Roles` and then click `New Role`.

{{< zoom-picture src="images/roles.webp" caption="The Roles Page" >}}
2. Fill out the form presented:
   {{< zoom-picture src="images/role-form.webp" caption="Create and Edit Role Form" >}}

#### Role Configuration Options

- **`Name`**: The name of the role, used to identify it within the system.

- **`Permissions for Role`**: A list of available permissions that can be assigned to the role. Select the permissions that define the role's access.

3. Click `Create Role` to save the new role in the system.


---

## Available Permissions

Roles grant the permissions below; when a user holds multiple roles, the permissions combine.

### Audit

| Permission | Description |
|---|---|
| View Audit Logs | View the audit log of system activity. |
| Download Audit Logs | Export audit log entries to a file. |

### System

| Permission | Description |
|---|---|
| View Cluster Info | View cluster node and topology information. |

### User Management

| Permission | Description |
|---|---|
| Manage Groups | Create, edit, and delete user groups. |
| Manage Roles | Create, edit, and delete roles and their permissions. |
| Manage Users | Create, edit, and delete user accounts. |

### Resource Management

| Permission | Description |
|---|---|
| Manage Spaces | Manage any space, including those owned by other users. |
| Manage Templates | Create, edit, and delete space templates. |
| Manage Variables | Create, edit, and delete system variables. |
| Manage Volumes | Create, edit, and delete volumes. |

### AI Tools

| Permission | Description |
|---|---|
| Use MCP Server | Connect to the knot MCP server. |
| Use Web Assistant | Use the built-in web AI assistant. |
| Manage MCP Servers | Register and configure MCP servers. |

### Scripting

| Permission | Description |
|---|---|
| Manage System Scripts | Create and edit system (global) scripts. |
| Execute System Scripts | Run system (global) scripts. |
| Manage Own Scripts | Create and edit your own scripts. |
| Execute Own Scripts | Run your own scripts. |

### Events, Skills & Slash Commands

| Permission | Description |
|---|---|
| Manage Own Event Sinks | Create and manage your own event sinks. |
| Manage Global Event Sinks | Create and manage global event sinks. |
| Manage Global Skills | Create and edit global skills. |
| Manage Own Skills | Create and edit your own skills. |
| Manage Global Slash Commands | Create and edit global slash commands. |
| Manage Own Slash Commands | Create and edit your own slash commands. |

### Stacks

| Permission | Description |
|---|---|
| Manage Global Stack Definitions | Create, edit, and delete global (system) stack definitions. |
| Manage Own Stack Definitions | Create, edit, and delete personal stack definitions. |
| Use Stack Definitions | Create spaces from stack definitions. |

### Methods, Tunnels & Pools

| Permission | Description |
|---|---|
| Use Space Methods Shared by Others | Call space methods shared by other users. |
| Use Tunnels | Expose a local or space port as a public URL via a knot tunnel. |
| Use Space Pools | Create and run space pools. |

### Space Operations

| Permission | Description |
|---|---|
| Use Spaces | Create and run spaces. |
| Set Space Dependencies | Configure dependencies between spaces. |
| Edit Space Jobs | Edit the scheduled jobs of your own spaces. |
| Use User Startup Script | Set a user startup script that runs when a space starts. |
| Share Spaces | Share your spaces with other users. |
| Transfer Spaces | Transfer ownership of your spaces to another user. |
| Use Code Server | Open code-server in a space. |
| View Logs | View the log window for a space. |
| Use SSH | Connect to spaces over SSH. |
| Use VNC | Use the VNC graphical desktop in a space. |
| Use VS Code Tunnel | Connect to a space via a VS Code tunnel. |
| Use Web Terminal | Use the web terminal in a space. |
| Run Commands | Execute commands inside a space. |
| Copy Files | Copy files to and from a space. |

{{< tip >}}
Knot Pro adds one further permission — **Use Log Sinks**, running a space that receives the logs of your other spaces. {{< pro-badge >}}
{{< /tip >}}

---

### Deleting a Role

To delete a role:

1. Select the menu item for the role you want to delete.
2. Click `Delete` and confirm the action.

---

### Editing a Role

Editing a role is similar to creating one:

1. Select the `Edit` option from the role menu.
2. Update the role details, such as its name or assigned permissions.
