---
title: Managing Groups
description: Create, edit, and delete groups that control template access and resource limits in knot.
type: Guide
tags: [security, authentication]
weight: 10
---

In Knot, groups are used to control access to templates and manage resource limits for users. For example, web developers may need access to PHP environments but not Go development environments used by DevOps teams.

Groups can also define limits for Compute and Storage Units, as well as other resources. When a user belongs to multiple groups, the limits from all groups are combined.

---

### Creating Groups

To create a new group:

1. From the `Administration` menu, select `Groups` and then click `New Group`.

{{< zoom-picture src="images/groups.webp" caption="The Groups Page" >}}
2. Fill out the form presented:
   {{< zoom-picture src="images/group-form.webp" caption="Group Create and Edit Form" >}}

#### Group Configuration Options

- **`Name`**: The name of the group, used to identify it within the system.

- **`Maximum Spaces`**: Limits the number of spaces a user can create as a member of this group. Set to a number greater than 0 to enforce a limit.

- **`Compute Units Limit`**: Limits the number of compute units a user can use as a member of this group. Set to a number greater than 0 to enforce a limit.

- **`Storage Units Limit`**: Limits the number of storage units a user can use as a member of this group. Set to a number greater than 0 to enforce a limit.

- **`Maximum Tunnels`**: Limits the number of tunnels a user can create as a member of this group. Set to a number greater than 0 to enforce a limit.

- **`File Storage (MB)`**: The [file storage](/docs/file-storage/), in MB, each member of this group adds to their quota. A member whose own and groups' values are all `0` gets the server default (unlimited unless configured); once any is non-zero they have a limit. See [Quotas](/docs/file-storage/operations/#quotas).

- **`Maximum Buckets`**: The number of [file storage](/docs/file-storage/) buckets each member of this group adds to their limit, with the same rules as File Storage (MB).

---

### Deleting a Group

To delete a group:

1. Select the menu item for the group you want to delete.
2. Click `Delete` and confirm the action.

---

### Editing a Group

Editing a group is similar to creating one:

1. Select the `Edit` option from the group menu.
2. Update the group details as needed.
