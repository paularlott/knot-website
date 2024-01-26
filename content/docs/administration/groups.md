---
title: Groups
weight: 30
---

## Overview

know allows groups to be defined, groups can be used to limit which templates each developer can see. For example web developers may need PHP environments but have no need for a Go development environment used by DevOps.

For this example two groups can be defined, `Web Developers` and `DevOps`, to define the groups from the `Groups` page select `Create Group`:

![](/docs/administration/create-group.webp)

Once the groups have been defined the templates can be edited and assigned to the appropriate groups, users can also be edited and assigned to the appropriate group.

Both users and templates can be assigned multiple groups.

## Template Groups

When creating or editing templates the groups that the template will be visible to can be selected. If not groups are selected then the template will be available to users in all groups.

![](/docs/administration/template-groups.webp)

## User Groups

When creating or editing users the groups that the user belongs to can be set.

When a user creates a space the templates that either have no groups or groups that overlap with that users groups will be shown.

![](/docs/administration/user-groups.webp)
