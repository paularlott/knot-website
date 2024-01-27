---
title: User Management
weight: 50
---

## Creating a User

From the menu select `Users` and then `Create User`:

![](/docs/administration/create-user.webp)

The `Preferred Shell` is used when the user opens a web based terminal into the space, the system will attempt to open the selected shell and if not found will look for another available shell. This can be changed per space when creating a space.

When connecting to a space via SSH and the client, the `SSH Public Key` if set will be passed to the space to allow password less logins. The user should set the `SSH Public Key` themselves by clicking their username in the top right.

`Timezone` is used within the spaces to set their timezones, clicking or typing in the field will generate a searchable list of available timezones.

`Roles` is the optional list of roles to assign a user, if no roles are assigned then the user will only have the ability to start spaces and interact with their spaces.

`Groups` defines the list of groups that a user will belong to, only templates that have no groups assigned or have groups overlapping those of the user will be available when creating a new space.

## Deleting a User

{{< callout type="warning" >}}
  When a user is deleted any spaces created by the user are also deleted and any data in associated volumes is lost.
{{< /callout >}}

Select the menu next to the user to delete, click `Delete` and confirm the action.

![](/docs/administration/user-menu.webp)


## Editing a User

Editing the user is similar to creating a new user, however it the password fields are left blank then the password for the user is left unchanged.
