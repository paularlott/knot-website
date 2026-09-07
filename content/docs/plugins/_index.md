---
title: Plugins
description: Extend knot with menus, pages, and permissions declared in script metadata - folder plugins with optional scriptling and Go peers.
type: Overview
tags: [plugins, scripting]
weight: 46
---

Knot can be extended with **plugins**: drop-in scripts (or folders of scripts) that add sidebar menu items, live pages, and their own permissions - without modifying or recompiling knot.

A plugin is declared entirely in its script's [metadata block](../scripting/) - the `# /// script` comments at the top of the file. Nothing a plugin declares is produced by running plugin code: knot reads the declarations, validates them at load, and only executes a plugin's handlers when a user opens its pages, in an environment bound to that user. A broken plugin can never affect server startup. The full metadata reference lives in [Writing Plugins](./writing-plugins/).

## What plugins can declare

| Declaration | Effect |
|---|---|
| `permissions` | Grants roles can carry, stored as text (`plugin.<name>.<id>`) and managed in the role editor |
| `[[tool.knot.menus]]` | Sidebar items - external links or internal - gated per item by permission and/or groups |
| `[[tool.knot.pages]]` | Live pages under `/plugins/<name>/…` whose handlers run per-request as the requesting user; a page may claim the post-login landing spot with `default = true` |
| `logo_light` / `logo_dark` | A logo (or themed pair) that replaces the main page logo (login included) while the plugin is loaded |
| `icon` on menus/pages | The plugin's own SVG asset, rendered inline and themed with the UI |
| `bin/` binaries | Optional scriptling plugin-protocol peers (e.g. written in Go) callable from handlers as `plugin.<name>` |

## Enabling plugins

Point the server at a folder of plugins:

```sh
knot server --plugins-path /etc/knot/plugins
```

or in `knot.toml`:

```toml
[server]
plugins_path = "/etc/knot/plugins"
```

or with `KNOT_PLUGINS_PATH`. With no plugins path configured, or an empty one, the whole plugin surface is hidden - no menu item, no admin page, no search entry, nothing.

Every member of a zone must be deployed the same folder; permissions and grants replicate with the cluster, the folder does not.

**The folder is the source of truth**: removing a plugin's folder is uninstall (its grants sit inert until it returns), renaming is uninstall + install, and updating means replacing the folder and restarting the server - plugins load at boot, never hot.

## In this section

- [Writing Plugins](./writing-plugins/) - a section of its own: packaging, the `[tool.knot]` metadata reference, and validation common to every plugin, then authoring [in Scriptling](./writing-plugins/scriptling/) and [in Go](./writing-plugins/go/), with [Plugin Pages](./writing-plugins/pages/) covering the dispatch model
- [Managing Plugins](./managing/) - the admin inventory, permissions and roles, lifecycle

Working examples live in [`examples/plugins`](https://github.com/paularlott/knot/tree/main/examples/plugins) in the repository.
