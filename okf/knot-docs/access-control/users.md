---
description: Create, edit, and delete users, and manage their roles, groups, and resource limits in knot.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/access-control/users/
sources:
    - resource: https://getknot.dev/docs/access-control/users/
status: stable
tags:
    - security
    - authentication
title: User Management
type: Guide
---
# User Management

This guide covers how to create, edit, and delete users in Knot, as well as manage their roles, groups, and resource limits.

---

## Creating a User

To create a new user:

1. From the `Administration` menu, select `Users` and then click `New User`.


2. Fill out the form presented:

### User Details

- **`Username`**:
  The username to assign to the user.

- **`Email`**:
  The user's email address, which they will use to log in.

- **`Preferred Shell`**:
  The shell to use when the user opens a web-based terminal into a space. If the selected shell is unavailable, the system will attempt to use another available shell. This can also be changed per space during space creation.

- **`Timezone`**:
  The timezone to set for the user's spaces. Typing in the field generates a searchable list of available timezones.

- **`GitHub Username`** *(optional)*:
  If set, the system will attempt to retrieve the user's public key(s) from GitHub.

- **`SSH Authorized Keys`** *(optional)*:
  If set, these keys will be passed to spaces to allow passwordless SSH logins. To add multiple keys, enter one public key per line. Users can set their own SSH authorized keys by clicking their username in the top-right corner of the interface.

---

### Setting a Password

- **`Password`**:
  The password to assign to the user. Users can change their password after logging in.

- **`Confirm Password`**:
  The password must be entered again to confirm. Both fields must match.

---

### Resource Limits

- **`Maximum Spaces`**:
  The maximum number of spaces the user can create. Set to `0` for no limit.

- **`Compute Units Limit`**:
  The maximum number of compute units the user can use. Set to `0` for no limit. Compute units are only calculated when spaces are running.

- **`Storage Units Limit`**:
  The maximum number of storage units the user can use. Set to `0` for no limit.

- **`Maximum Tunnels`**:
  The maximum number of tunnels the user can have at any one time. Set to `0` for no limit.

---

### Assigning Roles and Groups

- **`Roles`**:
  A list of optional roles to assign to the user. Roles define the user's permissions within the system.

- **`Groups`**:
  The groups the user will belong to. Users can only access templates that are either ungrouped or belong to groups they are a member of. Groups can also define Compute and Storage Unit limits.

Once all fields are completed, click `Create User` to save the new user.

---

## Deleting a User


When a user is deleted, any spaces they created are also deleted, and any data in associated volumes is permanently lost.


To delete a user:

1. Select the menu item for the user you want to delete.
2. Click `Delete` and confirm the action.

---

## Editing a User

Editing a user is similar to creating one:

1. Select the `Edit` option from the user menu.
2. Update the user's details, roles, groups, or resource limits as needed.

**Note**: If the password fields are left blank, the user's password will remain unchanged.

---

## Linked Users (Fast User Switching)

Linked users are the accounts a user may **become** — think fast user switching. The link is one way: link B on A's account and A can switch into B (B's spaces included) from the profile menu (`Switch User`), but B cannot become A. Switching back needs no link: the session always offers `Back to <your account>` to return to whoever authenticated.

- **Linking** is done in the user manager: edit a user and use the `Linked Users` section — the listed accounts are the ones the edited user will be able to become. Requires the `Link Users` permission, which is **impersonation-grade**: whoever holds it can link to any account — administrators included — and act as it fully. Grant it as sparingly as admin itself.
- **Unlinking** removes one account from that list. A session the linking user already has switched into that account keeps running until it switches back or expires — it simply cannot switch in again.
- **Unlinking** removes one account from that list; the other account is unaffected.
- **Switching** requires nothing beyond the link (the target must be active). Every switch — including switching back — is written to the audit log (`User Switch`), and refused attempts are recorded as `User Switch Denied`.
- The users list marks accounts that have linked users with a `Linked` badge.
- The API exposes the same operations: `PUT /api/users/{user_id}/linked-users/{linked_user_id}` to link and `DELETE` on the same path to unlink, both gated by the `link_users` permission.
