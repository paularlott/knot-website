---
title: Desktop Mode
description: Run Knot on your desktop as a tray application — the full server with a system tray icon and a first-run setup wizard.
type: Overview
tags: [server, configuration]
weight: 6
---

On a standard build, running `knot` with no subcommand starts the full server together with a system tray icon. This is desktop mode: the same server as [`knot server`](/reference/cli/knot/#knot-server), plus the tray and a browser-based first-run wizard. It is the simplest way to run Knot on a laptop or desktop.

```shell
knot
```

---

## First run: the setup wizard

If no configuration file is found — or the config enables no database backend — desktop mode serves the setup wizard instead of the server. The wizard runs on `127.0.0.1:3000` (reusing the port from the configured URL if one is set) and opens from the tray's **Open knot setup** menu item.

The wizard is pre-filled from any existing config and writes a complete `knot.toml` to `~/.knot/knot.toml`, validating required fields on save. After saving, it notifies you to quit Knot from the tray menu and reopen it so the new configuration is loaded cleanly. On the next start, the server runs directly.

---

## The tray menu

| Item | Action |
| ---- | ------ |
| **Open knot UI** | Open the web interface in your default browser |
| **Setup** | Open the setup wizard (while first-run setup is pending) |
| **Quit** | Shut the server down and exit |

The tray icon is monochrome and adapts to your menu bar or taskbar theme: a template icon on macOS, a theme-aware icon on Windows, and the light variant on Linux panels.

If no system tray is available (for example a headless Linux session), desktop mode falls back to running the server headless: it prints the URL to open and keeps running until Ctrl-C.

---

## Windows behaviour

On Windows, a bare `knot` relaunches itself with no console window, so the tray is not accompanied by a terminal. All subcommands (`knot server`, `knot space list`, ...) keep their normal console behaviour.
