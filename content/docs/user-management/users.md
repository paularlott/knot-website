---
title: User Management
weight: 10
---

## Creating a User

From the menu select `Users` and then `New User` and the following form will be presented:

{{< image src="../create-user.webp" alt="Creating a New User" >}}

The `Preferred Shell` is used when the user opens a web based terminal into the space, the system will attempt to open the selected shell and if not found will look for another available shell. This can be changed per space when creating a space.

When connecting to a space via SSH and the client, the `SSH Public Key` if set will be passed to the space to allow password less logins. The user should set the `SSH Public Key` themselves by clicking their username in the top right. When the `GitHub Username` is set the system will attempt to retrieve the users public key(s) from GitHub.

`Timezone` is used within the spaces to set their timezones, clicking or typing in the field will generate a searchable list of available timezones.

`Maximum Spaces` is the maximum number of spaces that the user can create, when set to 0 there's no limit applied.

`Compute Units Limit` is the maximum number of compute units that the user can use, when set to 0 there's no limit applied. The compute units in use is only calculated when the space is running.

`Storage Units Limit` is the maximum number of storage units that the user can use, when set to 0 there's no limit applied. The storage units in use is calculated for all spaces that have been started at least once.

`Roles` is the optional list of roles to assign a user, if no roles are assigned then the user will only have the ability to create and start spaces as well as interact with their spaces.

`Groups` defines the list of groups that a user will belong to, only templates that have no groups assigned or have groups overlapping those of the user will be available when creating a new space. Groups can also provide Compute and Storage Unit limits.

## Deleting a User

{{< callout type="warning" >}}
  When a user is deleted any spaces created by the user are also deleted and any data in associated volumes is lost.
{{< /callout >}}

Select the menu item for the user to delete, click `Delete` and confirm the action.

{{< image src="../user-menu.webp" alt="Delete User" >}}

## Editing a User

Editing the user is similar to creating a new user, however it the password fields are left blank then the password for the user is left unchanged.
