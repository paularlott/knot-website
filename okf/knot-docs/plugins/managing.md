---
description: The admin inventory, granting plugin permissions to roles, and the add/remove/rename lifecycle.
generated:
    by: knot-website/okf.py
resource: https://getknot.dev/docs/plugins/managing/
sources:
    - resource: https://getknot.dev/docs/plugins/managing/
status: stable
tags:
    - plugins
    - administration
title: Managing Plugins
type: Guide
---
# Managing Plugins

## The admin inventory

The **Plugins** page (in the sidebar's *More* section, `/plugins`, gated by the *View Plugins* permission, granted to the admin role by default) lists every plugin in the server's plugins path: loaded plugins with their declared permissions, menus, pages, peers (with health), and themed logos - plus failed plugins with their load reasons and any warnings (ignored files, unloadable binaries, multiple site-logo or default-page claimants). The inventory is read-only: the folder is the source of truth, so changes are made on disk and the server restarted.

`GET /api/plugins` returns the same data for automation.

## Granting plugin permissions

Plugin permissions appear in the role editor under a **Plugin Permissions** section, grouped per plugin, next to the core permissions. A grant is stored on the role as its qualified text name - `plugin.metrics.read_metrics` - which has two consequences worth knowing:

- Grants replicate with the role and mean the same thing on every node, whatever order the cluster starts in.
- A grant for an uninstalled plugin sits inert and returns if the plugin is reinstalled under the same name. Renaming a plugin deliberately does *not* carry grants - the name is the identity.

The admin role passes every plugin permission check without explicit grants.

## Lifecycle

| Action | Effect |
|---|---|
| **Install** | Drop the file or folder into the plugins path and restart the server |
| **Update** | Replace the folder, restart |
| **Uninstall** | Remove the folder, restart - data cleanup follows the folder, grants sit inert |
| **Rename** | Uninstall + install: new identity, grants don't transfer |

Plugins load at boot; there is no hot reload. A plugin present but failing validation keeps nothing registered and shows as failed - the server and every other plugin continue normally. When plugins gain their own durable storage, removal will also purge it, with a guard that refuses to treat an empty or unreadable plugins path (a possibly failed mount) as a mass uninstall; today an empty path simply loads no plugins.
